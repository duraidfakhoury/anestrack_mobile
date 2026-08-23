# Mobile — Offline Co-Sign

How a supervisor's bedside signature survives a ward with no internet.

Supplements `integration-mobile.md`. Base URL and auth headers are unchanged; every call below is
`{BASE}/functions/{name}` with the caller's session token.

> **This affects BOTH apps.** The student app and the supervisor app each hold one half of the
> protocol, and neither half is worth anything alone. They have to ship together.

---

## Contents

1. [The problem, and what changes](#1-the-problem-and-what-changes)
2. [The protocol](#2-the-protocol)
3. [The QR payload](#3-the-qr-payload)
4. [Supervisor app — issuing a bedside code](#4-supervisor-app--issuing-a-bedside-code)
5. [Student app — scanning and syncing](#5-student-app--scanning-and-syncing)
6. [Endpoint reference](#6-endpoint-reference)
7. [What the score does](#7-what-the-score-does)
8. [Rules you must not break](#8-rules-you-must-not-break)
9. [Edge cases and what to show the user](#9-edge-cases-and-what-to-show-the-user)
10. [What did NOT change](#10-what-did-not-change)

---

## 1. The problem, and what changes

A procedure's reliability score is built from signals. The biggest single one — 4 of 10 points —
is the **live co-sign**: the supervisor taps to sign at the point of care. That has always been a
round trip through the server, so in a ward with no signal it was impossible.

The result was backwards. An offline entry reached the server with no supervisor credential at
all, and it was scored against `loggedAt` — the moment the phone found Wi-Fi again, which might be
three days later. A student who logged correctly at the bedside **with the supervisor standing
next to them** scored 0 on the entry-time signal, was dropped to `Flagged` as an unvouched-for
late entry, and a synced backlog tripped the bulk-fabrication flag on top. The one case where
supervision was most certainly present was scored as if it were absent.

Offline co-sign closes that. The two phones exchange a secret at the bedside with no server
involved, each uploads its half whenever it next has internet, and the server matches them and
awards the co-sign then.

**The short version for the app:** the supervisor's phone shows a QR, the student scans it, both
phones remember it, both upload it later. Neither waits for the other.

---

## 2. The protocol

```
BEDSIDE — both phones offline
┌─────────────────────────┐                    ┌─────────────────────────┐
│  SUPERVISOR APP         │                    │  STUDENT APP            │
│  mints localId + code   │ ──── QR scan ────▶ │  stores them against    │
│  stores them + clock    │   (a few cm)       │  the entry + own clock  │
└─────────────────────────┘                    └─────────────────────────┘
            │                                              │
   hours or days later,                          hours or days later,
   whenever there is internet                    whenever there is internet
            │                                              │
            ▼                                              ▼
   submitOfflineAttestations              syncOfflineCoSignedProcedures
            │                                              │
            └──────────────────┬───────────────────────────┘
                               ▼
                    SERVER matches the two halves
                    → liveCoSign, procedure Approved
```

**Order does not matter.** Whichever half arrives second completes the pair. A supervisor who
syncs before the student has ever opened the app gets `matched: false` with a reason — that is a
normal outcome, not an error, and must not be shown as a failure.

**Why the supervisor mints the code and not the student.** The obvious design is the other way
round and it is wrong: a student could mint codes in advance for procedures that never happened
and get a busy supervisor to submit them later, with no bedside meeting ever taking place. With
the supervisor minting, a student acting alone can never produce a valid code.

**Why QR and not anything else.** The evidence is that the code travelled a few centimetres of
line-of-sight. If your app also lets the code be typed in, read aloud, or sent over WhatsApp, the
protocol proves nothing. **Do not add a manual-entry fallback.** BLE is an acceptable substitute
if you already have it working; nothing else is.

---

## 3. The QR payload

The server never sees the QR — it only ever receives the fields — so this shape is a contract
between the two apps, not with the backend. Both apps must agree on it exactly.

```json
{
  "v": 1,
  "localId": "8f2c91ab4d7e0355c1b6d924",
  "code": "3a91f0c7d4b28e6510af7c39d2e84b06",
  "witnessedAt": "2026-08-20T09:10:00.000Z"
}
```

| Field | Format | Who produces it |
| --- | --- | --- |
| `v` | Integer, `1` | Protocol version. Refuse a QR whose `v` you do not know. |
| `localId` | 24 lowercase hex chars (12 random bytes) | Supervisor device. Identifies **the bedside event**. |
| `code` | 32 lowercase hex chars (16 random bytes = 128 bits) | Supervisor device. The secret. |
| `witnessedAt` | ISO 8601, UTC, with milliseconds | Supervisor device clock at the moment the QR was shown. |

Use a **cryptographic** random source (`SecureRandom` / `Random.secure()`), not `Math.random()`
and not a timestamp-seeded PRNG. A guessable code is a forgeable co-sign.

The student app carries `witnessedAt` in the QR only so it can warn the student about a clock
disagreement before syncing; it does **not** send it to the server. The server gets `witnessedAt`
from the supervisor's own submission, which is the whole point of having two clocks.

---

## 4. Supervisor app — issuing a bedside code

**At the bedside (offline):**

1. Supervisor opens "Witness a procedure".
2. Mint `localId` and `code`; take `witnessedAt = now`.
3. Persist `{localId, code, witnessedAt, note?}` to a **local outbox** *before* rendering the QR.
   If the app is killed while the QR is on screen, the student may already have scanned it — an
   attestation the supervisor cannot upload is a student who loses their co-sign.
4. Show the QR. Keep it on screen for as long as the supervisor wants; there is no bedside
   timeout. The 72-hour window is for the *upload*, not the scan.

**Whenever internet returns:** POST the whole outbox to `submitOfflineAttestations` and mark the
rows sent. Re-sending is safe — see idempotency in §8.

`note` is optional free text ("ward 3, morning list"). It is never scored; it exists so a
supervisor can recognise what they signed when the confirmation arrives days later.

---

## 5. Student app — scanning and syncing

**At the bedside (offline):**

1. Student fills the procedure entry as usual — hospital, type(s), patient name, date.
2. `capturedAt = now`, taken **when the entry is written**, not when it is later synced.
3. Scan the supervisor's QR; store `localId` and `code` against the queued entry.
4. Queue the entry locally.

If the student saves an entry **without** scanning a code, it is an ordinary offline entry: queue
it for `syncOfflineProcedures` as you do today. Do not send it to the new endpoint — it will be
refused.

**Whenever internet returns:** POST the queued co-signed entries to
`syncOfflineCoSignedProcedures`.

One request may carry many bedside events; each is independent and each gets its own result. A
week of work does not fail because one entry names a hospital that has since been renamed.

---

## 6. Endpoint reference

### 6.1 `syncOfflineCoSignedProcedures` — POST — student

```json
{
  "procedures": [
    {
      "hospitalId": "aB3xY9",
      "procedureTypeIds": ["pt_01", "pt_07"],
      "patientName": "أحمد الحلبي",
      "procedureDate": "2026-08-20T09:00:00.000Z",
      "capturedAt":    "2026-08-20T09:10:00.000Z",
      "localId": "8f2c91ab4d7e0355c1b6d924",
      "coSignCode": "3a91f0c7d4b28e6510af7c39d2e84b06",
      "notes": "optional"
    }
  ]
}
```

`procedureTypeId` (singular) still works for one type. `procedureTypeIds` logs several types
performed on the same patient in one bedside event as separate rows — one attestation co-signs
all of them.

**Response**

```json
{
  "successCount": 1,
  "failureCount": 0,
  "coSignedCount": 1,
  "pendingCount": 0,
  "results": [
    {
      "index": 0,
      "success": true,
      "claimId": "cLm001",
      "sessionId": "5f1c...",
      "procedureIds": ["pR001", "pR002"],
      "coSigned": true,
      "coSignPending": false,
      "clockSkewMinutes": 2,
      "flaggedForReview": false,
      "detail": "Co-signed by the supervisor attestation"
    }
  ]
}
```

| Field | Meaning |
| --- | --- |
| `coSigned` | The supervisor's half was already there. The procedure is **Approved** and fully scored. |
| `coSignPending` | Uploaded fine; still waiting for the supervisor. **Not an error.** |
| `clockSkewMinutes` | How far the two device clocks disagreed. Absent until matched. |
| `flaggedForReview` | Matched, co-signed, and sent to an admin because the clocks disagreed past 15 minutes. |
| `alreadySynced` | This `localId` was already uploaded. Treat as success and clear it from the queue. |
| `detail` | Human-readable; safe to log, not written for end users. |

### 6.2 `submitOfflineAttestations` — POST — supervisor only

```json
{
  "attestations": [
    {
      "localId": "8f2c91ab4d7e0355c1b6d924",
      "coSignCode": "3a91f0c7d4b28e6510af7c39d2e84b06",
      "witnessedAt": "2026-08-20T09:10:00.000Z",
      "note": "optional"
    }
  ]
}
```

**Response**

```json
{
  "successCount": 1,
  "failureCount": 0,
  "matchedCount": 1,
  "results": [
    {
      "index": 0,
      "success": true,
      "attestationId": "aTt001",
      "matched": true,
      "procedureIds": ["pR001", "pR002"],
      "clockSkewMinutes": 2,
      "flaggedForReview": false,
      "detail": "Matched the student claim and co-signed it"
    }
  ]
}
```

`matched: false` with `detail: "Waiting for the student to sync the procedure"` is the expected
result when the supervisor syncs first. Show it as *pending*, never as *failed*.

Called by a non-supervisor: `403 Only a supervisor can submit an offline attestation`.

### 6.3 `getOfflineCoSignStatus` — GET — any authenticated user

No parameters. Returns both arrays; each is filtered to the caller, so a student gets `claims`
populated and `attestations` empty, and a supervisor the reverse.

```json
{
  "claims": [
    {
      "id": "cLm001",
      "localId": "8f2c...",
      "sessionId": "5f1c...",
      "status": "AwaitingAttestation",
      "capturedAt": "2026-08-20T09:10:00.000Z",
      "submittedAt": "2026-08-23T14:00:00.000Z",
      "expiresAt": "2026-08-26T14:00:00.000Z",
      "matchedAt": null,
      "clockSkewMinutes": null,
      "supervisorId": null,
      "supervisorName": null
    }
  ],
  "attestations": [
    {
      "id": "aTt001",
      "localId": "8f2c...",
      "witnessedAt": "2026-08-20T09:10:00.000Z",
      "submittedAt": "2026-08-20T18:30:00.000Z",
      "expiresAt": "2026-08-23T18:30:00.000Z",
      "matched": true,
      "expired": false,
      "matchedAt": "2026-08-23T14:00:00.000Z",
      "claimedByName": "أحمد الحلبي",
      "note": null
    }
  ]
}
```

`claims[].status` is `AwaitingAttestation` | `Matched` | `Expired`.

This is the screen that answers *"I scanned the code — did it work?"*. Without it the student can
only infer the answer from a score that moved or did not.

---

## 7. What the score does

Reliability is scored out of 10 and the level is `Verified` | `Attested` | `Flagged`.

| Moment | Entry-time | Co-sign | Proximity | Score | Level |
| --- | --- | --- | --- | --- | --- |
| Offline entry synced, no attestation yet | +2 | — | — | **2** | Attested |
| Attestation matches | +2 | +4 | +2 | **8** | **Verified** |
| No attestation inside 72 h | +2 | — | — | **2** | **Flagged** (`UNCONFIRMED`) |

The entry-time points come from `capturedAt`, not from the sync time — that is the fix for the
"logged three days late" problem. The server clamps `capturedAt` into
`[procedureDate, serverReceivedAt]`; a value outside that range is ignored entirely and the entry
falls back to being scored on its sync time, so **a wrong device clock costs the student points**.
Take `capturedAt` from the system clock at the moment of writing and never let the user edit it.

On a match the procedure also goes straight to **`status: "Approved"`** — the same as an online
live co-sign. There is no separate supervisor review afterwards.

If nothing matches within 72 hours the record is flagged `UNCONFIRMED`, which drops it to
`Flagged` for an admin. It is not deleted and not rejected; it says plainly that the supervision
behind it was never corroborated.

---

## 8. Rules you must not break

1. **The code travels by QR only.** No manual entry, no copy-paste, no sharing sheet. The entire
   evidentiary value is that it could not have travelled over a network.
2. **Cryptographic randomness** for `localId` and `code`.
3. **Persist before you display / before you queue.** Both sides must write their half to local
   storage before the QR goes on screen (supervisor) or before the scan screen closes (student).
4. **`capturedAt` and `witnessedAt` are device clocks read at the bedside.** Never the sync time,
   never user-editable, always UTC ISO 8601.
5. **`localId` is the idempotency key on both endpoints.** Re-sending a queue is safe and
   expected: the server returns `alreadySynced` / `alreadySubmitted` and does not write twice.
   Keep the same `localId` across retries — do not mint a new one.
6. **Delete the local `code` once its half is accepted.** A code sitting in an app database after
   it has been used is a liability with no remaining purpose.
7. **Never send the code anywhere except its own endpoint.** Not in logs, not in crash reports,
   not in analytics.

---

## 9. Edge cases and what to show the user

| Situation | Response | Show the user |
| --- | --- | --- |
| Student syncs first | `coSignPending: true` | "Waiting for your supervisor's signature" — with the entry visible and counted as pending |
| Supervisor syncs first | `matched: false`, "Waiting for the student…" | "Signature saved, waiting for the student" |
| Neither syncs within 72 h | claim `status: "Expired"` | "This signature expired. Ask your supervisor to confirm the procedure instead." — then use the existing `requestConfirmation` flow |
| Clocks disagree > 15 min | `flaggedForReview: true`, still co-signed | "Recorded and sent for review — your device clock differs from your supervisor's." Prompt them to enable automatic date & time |
| Supervisor scans their own student account | `403` / no match | Should be impossible in the UI; a supervisor can never attest to their own procedure |
| Same QR scanned by two students | Only the first matches | Second gets `coSignPending` forever, then expires. Take the QR off screen after a scan |
| Entry with no code | `400`, "…use syncOfflineProcedures" | Route it to the old endpoint instead — this is a client bug, not a user error |
| Duplicate sync after a lost response | `alreadySynced: true` | Nothing. Clear the queue item |

**The supervisor gets a push when their attestation is claimed**, naming the student. That is
deliberate and it is the only chance to catch a code that reached the wrong person — the
supervisor learns nothing about who scanned the QR at the bedside. Surface that notification
prominently and give it a way to reach an admin.

---

## 10. What did NOT change

Nothing in the existing flows moved. Specifically:

- **`createProcedure`** — unchanged. Same parameters, same response, same scoring.
- **`syncOfflineProcedures`** — unchanged. Offline entries with no bedside code still go here and
  behave exactly as they did before. They are still scored on their sync time, because without an
  attestation the server has no way to know the entry was written any earlier than it arrived.
- **`coSignProcedure` / `confirmProcedure` / `reviewProcedure`** — unchanged.
- The Procedure record gained one optional field, `capturedAt`, present only on offline entries.

If you ship the new endpoints and something is wrong with them, the online flows are unaffected.
That isolation is intentional and worth preserving: do not "simplify" later by folding these
endpoints back into the existing ones.
