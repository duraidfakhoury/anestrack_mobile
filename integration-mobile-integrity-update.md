# Mobile — Procedure Integrity Update

**Yes, there are mobile changes.** They are all *read-side*: no new endpoints for the app, no new
screen the student drives. But one of them will visibly break an existing screen if ignored.

Supplements `integration-mobile.md`; nothing in that guide is contradicted, only extended.

---

## Why this exists

Until now an approved procedure was final. If an admin later discovered a record was fabricated,
there was no way to take it back — it counted towards the student's training log forever. The only
tool was a hard delete, which was worse: it destroyed the evidence and broke the student's hash
chain.

A disputed record is now **struck, not deleted**. It stays in the log with its full history — its
hash, its reliability score, its co-sign evidence — and simply stops counting.

---

## 1. ⚠️ `status` gained two values — the one thing that can break your UI

```
Pending | Approved | Rejected | UnderInvestigation | Revoked
```

Any `switch` on `status`, status chip, colour map, icon lookup or filter dropdown that only knows
the first three will render an **empty label** for these rows. This is the only breaking change in
the release.

| Status | Meaning to the student | Counts towards the training log? | Editable? |
| --- | --- | --- | --- |
| `Pending` | Waiting for the supervisor | No | Yes |
| `Approved` | Signed off | **Yes** | No |
| `Rejected` | The supervisor said no | No | Yes |
| `UnderInvestigation` | An admin froze it while a dispute is looked into | No — but not final | **No** |
| `Revoked` | An admin struck it (fabrication, duplicate, …) | No — final unless reinstated | **No** |

Suggested Arabic labels — confirm with the supervisor before shipping:
`UnderInvestigation` → **قيد التحقيق**, `Revoked` → **ملغى**.

### Only an admin can set these two — and the reason matters for the UI

Not seniority: **the supervisor is a subject of the investigation.** A fabricated record only
reaches `Approved` because a reviewer signed it off, so every revocation implicates the reviewer
as much as the student.

So do not build a supervisor shortcut for these, in any form. The backend refuses it on every
door — `reviewProcedure` accepts only `Approved` \| `Rejected`, and a raw class-API write of
`status` is refused with 119 — so any such control would be dead UI.

---

## 2. Six new fields on every procedure row

`listProcedures`, `getProcedure` and the co-sign/confirm responses all carry them. They are
`null` on the overwhelming majority of rows — populated only once an admin has acted.

```json
{
  "status": "Revoked",
  "statusBeforeIntegrityAction": "Approved",
  "integrityAction": "Revoke",
  "integrityReason": "Fabrication",
  "integrityNote": "No patient by this name in the hospital record for that date.",
  "integrityActionAt": { "__type": "Date", "iso": "2026-08-22T09:14:02.118Z" },
  "integrityActionBy": { "id": "9KpQ2mXr4T", "firstName": "…", "lastName": "…" }
}
```

| Field | Use it for |
| --- | --- |
| `integrityNote` | **Show this to the student.** The admin's written justification — the only place they learn why. |
| `integrityReason` | A code from a fixed list (below). Translate it; do not display raw. |
| `integrityActionAt` | "Struck on 22 Aug 2026" |
| `integrityActionBy` | Who decided. Optional to display. |
| `statusBeforeIntegrityAction` | What it will return to if reinstated. Mostly internal. |
| `integrityAction` | `OpenInvestigation` \| `Revoke` \| `Reinstate` — the last action taken. |

`integrityReason` is one of:
`Fabrication`, `PatientMismatch`, `DuplicateEntry`, `SupervisorDenial`, `UnauthorizedApproval`,
`AdminError`, `Other`.

Note `AdminError` means **no misconduct** — the record or its approval was simply a mistake. Do
not word that one as an accusation.

---

## 3. The record becomes read-only

Editing a record in either state through the class API returns **119**:

```json
{"code":119,"error":"This procedure is revoked and can only be changed by an administrator"}
```

Disable edit affordances when `status` is `UnderInvestigation` or `Revoked` — the same way you
already do for `Approved`.

---

## 4. New error case on the supervisor flows

`coSignProcedure`, `confirmProcedure` and `requestConfirmation` now refuse a frozen or struck
record with **119**:

```json
{"code":119,"error":"This procedure is under investigation — only an administrator can decide it"}
```

This closes a real hole: without it, an admin would strike a fabricated record and the next
supervisor tap would silently set it back to `Approved`. Surface the message and refresh the
list — do not retry.

Per-row, not per-session: if an admin struck one type of a multi-type session and left the rest
standing, one co-sign still resolves the remaining types normally.

---

## 5. The supervisor's queue quietly shrinks

`listPendingForSupervisor` now excludes frozen and struck records. No client change needed — but
if a supervisor reports an item "disappearing" from their queue, this is why. Refresh on resume.

---

## 6. Push notifications — no client change

The student gets a push the moment an action is taken. It reuses the existing types, so your
routing already works:

| Action | `data.type` | Title |
| --- | --- | --- |
| Investigation opened | `Rejection` | Procedure under investigation |
| Revoked | `Rejection` | Procedure revoked |
| Reinstated | `Approval` | Procedure reinstated |

The body carries the reason and the admin's note, e.g.
`Your procedure has been revoked and no longer counts towards your training log. Reason:
Fabrication — No patient by this name in the hospital record for that date.`

---

## 7. What the app must NOT build

- **No appeal or dispute button.** There is no student-facing endpoint for contesting a decision,
  and none is planned. The student is a passive recipient here.
- **No delete.** `deleteProcedure` has been removed from the backend entirely. Any call returns
  `{"message":"Function not found"}`. If the app has a delete affordance anywhere, remove it.
- **No admin actions in the mobile app.** `openInvestigation`, `revokeProcedure`,
  `reinstateProcedure` and `listIntegrityActions` are SuperAdmin-only and belong to the dashboard.

---

## Checklist

- [ ] Add `UnderInvestigation` and `Revoked` to every status enum, chip, colour map and filter
- [ ] Add the six `integrity*` fields to the procedure model (all nullable)
- [ ] Show `integrityNote` + translated `integrityReason` on a struck/frozen record
- [ ] Treat both states as read-only, like `Approved`
- [ ] Handle 119 on `coSignProcedure` / `confirmProcedure` / `requestConfirmation`
- [ ] Remove any delete-procedure affordance
