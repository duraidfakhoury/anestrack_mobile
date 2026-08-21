# AnesTrack — Mobile Integration Guide

Base URL: `https://anestrack.justfortesting.ovh/api`

Every endpoint below is a **cloud function**, called as `POST|GET|PUT {base}/functions/{name}`.
The HTTP verb is part of the contract — calling a function with the wrong verb returns
`405 Method not allowed`.

You do not need the Parse SDK. Plain HTTP with three headers is enough.

---

## 1. Auth headers

Every call carries these two:

```
X-Parse-Application-Id: myapp1234566
X-Parse-REST-API-Key:   <rest api key>
Content-Type:           application/json
```

Once the user logs in, add their session token:

```
X-Parse-Session-Token: r:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Never send `X-Parse-Master-Key`

Two separate reasons, both serious:

1. **It breaks the call.** A valid master key makes the request a *master request*, and Parse
   then **ignores `X-Parse-Session-Token` entirely** — `req.user` becomes `undefined` on the
   server. Every user-scoped endpoint fails with `Permission denied` even though your session
   token was perfectly valid. If you are getting `{"code":1,"error":"Permission denied"}` on a
   call that should work, this is almost always why.
2. **It must never ship in a binary.** The master key bypasses all permissions on all data for
   all users. Anything in an APK/IPA is extractable. It belongs on a server, never in the app.

---

## 2. Push registration lifecycle

The backend addresses **devices**, not users. One user can have several registered devices (the
phone, a tablet, the web dashboard) and **all of them receive every push**.

### `registerDevice` — POST

Call it **after FCM `getToken()`**, and again on **every `onTokenRefresh`**. Calling it repeatedly
with the same token is safe and cheap — it updates the existing row rather than creating a second.

```http
POST /api/functions/registerDevice
X-Parse-Session-Token: r:...

{
  "token": "fcm-registration-token-from-firebase",
  "platform": "android",
  "deviceInfo": "Pixel 8 / Android 15 / app 1.4.2"
}
```

`platform` must be one of `web`, `android`, `ios` — anything else returns 142. `deviceInfo` is a
free-text debugging hint and is optional.

```json
{
  "registered": true,
  "device": {
    "id": "R4ZJkTsrFD",
    "platform": "android",
    "deviceInfo": "Pixel 8 / Android 15 / app 1.4.2",
    "lastSeenAt": {"__type": "Date", "iso": "2026-08-18T14:14:27.628Z"},
    "createdAt": {"__type": "Date", "iso": "2026-08-18T14:14:27.628Z"},
    "updatedAt": {"__type": "Date", "iso": "2026-08-18T14:14:27.628Z"}
  },
  "topics": {"subscribed": ["all", "type_Student", "year_1"], "failed": []}
}
```

The FCM token itself is **never echoed back** in any response — it is a credential, and you
already have it.

#### The `topics` field

Broadcast pushes (announcements, new lectures) are delivered by FCM **topic**, and this is where
the device joins them: `all`, `type_{userType}`, and for students `year_{yearCode}`.

Subscribing means up to three round trips to Google, so the endpoint waits only a bounded moment
for them. You get one of two shapes:

| `topics` value | Meaning |
| --- | --- |
| `{"subscribed": [...], "failed": [...]}` | Settled. `failed` non-empty ⇒ this device will still get **direct** pushes but will miss **broadcasts**. |
| `{"pending": true}` | Firebase was slow; subscription is finishing in the background. |

When it comes back `pending`, the outcome is written onto the device row afterwards — read it back
later with `listMyDevices` as `topicsSubscribed` (boolean) and `topicsFailed` (array).

### `unregisterDevice` — POST

Call this **before** you clear the session on logout. Once the session token is gone you can no
longer prove ownership of the device row.

```http
POST /api/functions/unregisterDevice
{ "token": "fcm-registration-token-from-firebase" }
```

```json
{"unregistered": true, "topics": {"failed": []}}
```

It deletes the row and unsubscribes the token from its topics. `topics` mirrors `registerDevice`:
the settled per-topic outcome when Firebase answers quickly, or `{"pending": true}` when it does
not — the row is deleted either way, so you can ignore the field and log out immediately. Only the
device's own owner may unregister it (anyone else gets 101), so one user cannot silence another's
phone.

If you skip it, the previous user keeps receiving pushes on that handset until someone registers
the token again. The backend does defend against this — **registering a token that already belongs
to someone else MOVES it to the new owner** — but that only helps once the next user actually logs
in and registers. Unregister on logout.

### `listMyDevices` — GET

```http
GET /api/functions/listMyDevices
```

```json
[
  {
    "id": "R4ZJkTsrFD",
    "platform": "android",
    "deviceInfo": "Pixel 8 / Android 15",
    "lastSeenAt": {"__type": "Date", "iso": "2026-08-18T14:14:27.628Z"},
    "topicsSubscribed": true,
    "topicsFailed": [],
    "createdAt": {"__type": "Date", "iso": "2026-08-18T14:14:27.628Z"},
    "updatedAt": {"__type": "Date", "iso": "2026-08-18T14:14:28.101Z"}
  }
]
```

Useful for a "signed-in devices" screen, and for confirming a `pending` subscription later resolved.

---

## 3. Push payload shape

Every push carries **both** an FCM `notification` block and a `data` block:

```json
{
  "notification": {
    "title": "Procedure co-signed",
    "body":  "Your supervisor co-signed the procedure at the point of care."
  },
  "data": {
    "type":           "Approval",
    "channel":        "",
    "notificationId": "8xKp2mQrTz",
    "sentAt":         "2026-08-18T14:31:07.221Z"
  }
}
```

**Every `data` value is a string** — that is an FCM requirement, not a style choice. `channel` is
`""` for a direct push, or the topic name (`all`, `year_3`) for a broadcast.

Because a `notification` block is present:

- **Backgrounded / killed:** Android and iOS render the tray notification themselves. Your code is
  not invoked to display it. On tap you receive the `data` block for routing.
- **Foreground:** your handler (`FirebaseMessaging.onMessage`) receives both blocks and you draw
  the in-app toast yourself from `notification.title` / `notification.body`.

`data.type` is one of exactly four values: **`Approval`**, **`Rejection`**, **`Announcement`**,
**`Lecture`**.

```dart
void handleTap(Map<String, dynamic> data) {
  final id = data['notificationId'];
  if (id != null && id.isNotEmpty) {
    api.put('/functions/markAsRead', {'id': id});   // dismiss the in-app badge
  }

  switch (data['type']) {
    case 'Approval':
    case 'Rejection':
      navigator.push(ProceduresScreen());     // a procedure was co-signed / confirmed / rejected
      break;
    case 'Announcement':
      navigator.push(AnnouncementsScreen());
      break;
    case 'Lecture':
      navigator.push(LecturesScreen());
      break;
  }
}
```

`data.notificationId` is the id of the stored `Notification` row — pass it straight to
`markAsRead`. Related endpoints: `listNotifications` (GET, paged), `getUnreadCount` (GET),
`markAsRead` (PUT `{id}`), `markAllAsRead` (PUT).

**Delivery is best effort; the record is not.** The notification row is saved first and pushed
afterwards, so a user with no registered device — or with push permission denied — still sees the
item in `listNotifications`. Do not treat push as the only delivery path: fetch the list on resume.

---

## 4. The three procedure flows

### Flow 1 — live co-sign at the bedside (highest assurance)

The student logs the procedure and the server mints a **one-time code**. The two phones exchange it
over BLE or a QR code, which is what proves the supervisor was physically present.

**Step 1 — student:**

```http
POST /api/functions/createProcedure
{
  "hospitalId": "7lagecHXDB",
  "procedureTypeId": "aB3xY9kLmN",
  "patientName": "محمد العبد الله",
  "procedureDate": "2026-08-18T09:15:00.000Z",
  "supervisorId": "5D4NGPq941",
  "requestLiveCoSign": true,
  "notes": "تم الإجراء دون اختلاطات"
}
```

The response contains `coSignCode`. **It is returned exactly once and can never be retrieved
again** — hold it in memory, show it as a QR / broadcast it over BLE, and never persist it.

```json
{
  "objectId": "OwjpCnRTDA",
  "coSignStatus": "Awaiting",
  "coSignExpiresAt": {"__type": "Date", "iso": "2026-08-18T09:25:00.000Z"},
  "confirmationStatus": "NotRequired",
  "reliabilityScore": 2,
  "coSignCode": "a543d3e1f0c7bdb234d73b0e5cc18e13"
}
```

`supervisorId` is optional in this flow — whoever holds the code and co-signs becomes the
supervisor. Include it if you also want the item to appear in that supervisor's pending list.

**Step 2 — supervisor (optional preview):**

```http
GET /api/functions/getCoSignContext?coSignCode=a543d3e1...
```

```json
{
  "procedureId": "OwjpCnRTDA",
  "studentName": "أحمد الحلبي",
  "procedureType": "تنبيب رغامي",
  "expiresAt": {"__type": "Date", "iso": "2026-08-18T09:25:00.000Z"}
}
```

Deliberately non-PII — **no patient name** reaches the supervisor's pre-tap screen.

**Step 3 — supervisor co-signs:**

```http
POST /api/functions/coSignProcedure
{
  "coSignCode": "a543d3e1f0c7bdb234d73b0e5cc18e13",
  "proximity": {"method": "BLE", "rssi": -52}
}
```

`proximity` is `{"method":"BLE","rssi":<int>}` or `{"method":"QR"}`. Result: `status: "Approved"`,
`coSignStatus: "CoSigned"`, `assuranceLevel: "Verified"`.

Two hard rules:

- **The window is `COSIGN_WINDOW_MIN` — 10 minutes by default.** After `coSignExpiresAt` the code
  is dead and the record drops out of the supervisor's queue.
- **The code is single-use.** A replay returns `{"code":142,"error":"This co-sign code has already
  been used"}`.

There is a fallback for when BLE and QR are both unavailable: `coSignProcedure` with `{"id":
"<procedureId>"}` instead of `coSignCode`. Same tap, but **no proof of presence** — the record
scores lower.

### Flow 2 — async confirmation

The student names a supervisor at logging time; the supervisor confirms later, within
`CONFIRMATION_DEADLINE_HOURS` (**48 hours** by default).

```http
POST /api/functions/createProcedure
{
  "hospitalId": "7lagecHXDB",
  "procedureTypeId": "aB3xY9kLmN",
  "patientName": "فاطمة الحموي",
  "supervisorId": "5D4NGPq941"
}
```

→ `confirmationStatus: "PendingConfirmation"` plus a `confirmationDeadline`.

Then, **as the named supervisor** — note the verb is **PUT**:

```http
PUT /api/functions/confirmProcedure
{
  "id": "kwXGK1cQj2",
  "decision": "Confirm",
  "notes": "تم التأكيد بعد مراجعة التوثيق"
}
```

`decision` must be exactly `"Confirm"` or `"Reject"`. Only the named supervisor may decide, and a
supervisor can never confirm their own procedure.

### Flow 3 — emergency, and rescuing a lapsed co-sign

Pass `"isEmergency": true` to `createProcedure` for a case handled with no supervisor present; the
on-call supervisor confirms it afterwards through Flow 2.

If a live co-sign lapsed with nobody named, the **student** can still name a supervisor:

```http
POST /api/functions/requestConfirmation
{ "id": "OwjpCnRTDA", "supervisorId": "5D4NGPq941" }
```

It is accepted only when **all** of these hold, so surface a clear message rather than retrying:

| Precondition | Error if violated |
| --- | --- |
| Caller is the student who logged it | 119 `Only the student who logged this procedure can request confirmation` |
| `coSignStatus === "Expired"` **and** `confirmationStatus === "NotRequired"` | 142 `This procedure is not awaiting a supervisor to be named` |
| The record does not yet carry the `UNCONFIRMED` flag | 142 `The window to name a supervisor for this procedure has closed` |
| The named user is a Supervisor/SuperAdmin, and is not the student themselves | 142 / 119 |

The grace period is enforced by a background job that raises `UNCONFIRMED`; once that has run the
record is closed for good.

### The supervisor's queue

```http
GET /api/functions/listPendingForSupervisor?limit=50
```

Returns everything awaiting *this* supervisor — both branches at once: live co-signs still inside
their window, and records pending async confirmation. Supports `limit` / `skip` / `withCount`.

Rows now resolve `student` to a real object, so the queue can show who is asking:

```json
[
  {
    "id": "ueQp4JPrYS",
    "student": {"id": "DRSWFGAJ8m", "firstName": "أحمد", "lastName": "الحلبي", "yearCode": 1},
    "hospital": {"id": "7lagecHXDB", "name": "المشفى الوطني"},
    "procedureType": {"id": "aB3xY9kLmN", "name": "تنبيب رغامي"},
    "patientName": "لبنى الشيخ",
    "coSignStatus": "NotRequested",
    "confirmationStatus": "PendingConfirmation",
    "sessionId": "a3f81c9e2b7d4a5f",
    "sessionSize": 2
  }
]
```

---

## 5. Multi-type procedures — one bedside event, several types

A single case often covers more than one procedure type on the same patient. **Do not send two
`createProcedure` calls.** Send one, with an array:

```http
POST /api/functions/createProcedure
{
  "hospitalId": "7lagecHXDB",
  "procedureTypeIds": ["aB3xY9kLmN", "uTQsOEXasm"],
  "patientName": "محمد العبد الله",
  "supervisorId": "5D4NGPq941",
  "requestLiveCoSign": true
}
```

`procedureTypeIds` accepts a real JSON array (or a JSON-encoded string). The old singular
`procedureTypeId` still works and is unchanged.

### Response shape depends on the count

**One type → the flat object, exactly as before.** Nothing about your existing single-type code
changes.

**Two or more → a session envelope:**

```json
{
  "sessionId": "a3f81c9e2b7d4a5f",
  "sessionSize": 2,
  "coSignCode": "a543d3e1f0c7bdb234d73b0e5cc18e13",
  "procedures": [
    {"objectId": "row1", "procedureType": {"objectId": "aB3xY9kLmN"}, "sessionId": "a3f81c9e2b7d4a5f", "sessionSize": 2},
    {"objectId": "row2", "procedureType": {"objectId": "uTQsOEXasm"}, "sessionId": "a3f81c9e2b7d4a5f", "sessionSize": 2}
  ]
}
```

Branch on the presence of `procedures` (or on `sessionSize > 1`).

### What the backend guarantees

- **One row per type.** That is what makes the training-log report count the case once against
  *each* type — which is the whole point, and why the types are not stored as an array on one row.
- **One code, one tap.** A multi-type session mints a **single** `coSignCode`, and one
  `coSignProcedure` (or one `confirmProcedure`) resolves **every** row in the session. The
  supervisor never signs the same bedside event twice.
- **Duplicates collapse.** Sending the same type id twice yields one row, not two.
- **All-or-nothing.** If any id is unknown the whole call fails with 101 and **nothing is written**
   — there is no half-logged session to clean up.
- The photo, if you send one, is uploaded once and linked from every row.

### In the UI

Group by `sessionId` and render the group as **one case** with several type chips. `sessionSize`
tells you how many rows to expect. Single-type procedures also carry a `sessionId` (of size 1), so
grouping logic can be uniform.

A supervisor may split a decision across a session — confirm one type, reject another — by passing
the subset explicitly:

```http
PUT /api/functions/confirmProcedure
{ "id": "row1", "decision": "Reject", "ids": ["row1"] }
```

Omit `ids` for the normal case (decide the whole session at once).

---

## 6. The student's own log — `listProcedures`

```http
GET /api/functions/listProcedures?limit=20&skip=0
```

Filters: `status`, `assuranceLevel`, `flag`, `worstFirst`, `studentId`, plus `limit` / `skip` /
`withCount`.

Two things to know:

1. **A student is scoped automatically.** No filter needed — a Student caller only ever sees their
   own rows. Passing another user's `studentId` returns **119
   `Students can only list their own procedures`**. Supervisors and admins are not scoped.
2. **`student` and `supervisor` now resolve** to real objects instead of being missing from the
   response, and rows use the mapped shape.

```json
[
  {
    "id": "kwXGK1cQj2",
    "student": {"id": "DRSWFGAJ8m", "firstName": "أحمد", "lastName": "الحلبي"},
    "supervisor": {"id": "5D4NGPq941", "firstName": "سامر", "lastName": "قاسم"},
    "hospital": {"id": "7lagecHXDB", "name": "المشفى الوطني"},
    "procedureType": {"id": "aB3xY9kLmN", "name": "تنبيب رغامي"},
    "patientName": "محمد العبد الله",
    "status": "Approved",
    "confirmationStatus": "Confirmed",
    "coSignStatus": "NotRequested",
    "reliabilityScore": 4,
    "assuranceLevel": "Attested",
    "sessionId": "a3f81c9e2b7d4a5f",
    "sessionSize": 2,
    "createdAt": "2026-08-18T07:10:20.643Z"
  }
]
```

Full row fields: `id, student, supervisor, hospital, procedureType, procedureDate, patientName,
status, notes, reviewedAt, isOffline, photo, loggedAt, entryGapMinutes, reliabilityScore,
assuranceLevel, reliabilitySignals, reliabilityFlags, recordHash, prevHash, liveCoSign,
proximityVerified, asyncConfirmed, bodyPhoto, coSignStatus, coSignExpiresAt, supervisorCoSignedAt,
proximityEvidence, confirmationStatus, confirmationDeadline, isEmergency, sessionId, sessionSize,
createdAt, updatedAt`.

Enums worth hard-coding: `status` = `Pending | Approved | Rejected`;
`assuranceLevel` = `Verified | Attested | Flagged`;
`coSignStatus` = `NotRequested | Awaiting | CoSigned | Expired`;
`confirmationStatus` = `NotRequired | PendingConfirmation | Confirmed | Rejected | Expired`.

---

## 7. Error codes

The body is always `{"code": <n>, "error": "<message>"}`. The message is written to be shown to a
user; prefer it over inventing your own copy.

| Code | Meaning | What the app should do |
| --- | --- | --- |
| `101` | Object not found — bad id, or a device that isn't yours | Show "not found"; refresh the list |
| `119` | Operation forbidden — wrong role, someone else's record, own procedure | Show the message; do **not** retry |
| `142` | Validation error — bad enum, expired/used co-sign code, wrong state | Show the message; fix input and retry |
| `1` | Internal / permission denied | If it says *Permission denied*, you are sending the master key or have no valid session — re-login |
| `209` | Invalid session token | Session expired → force re-login |

---

## 8. Gotchas

- **GET params are always strings.** Query-string values arrive as text, so `limit=20` is `"20"`.
  Never send booleans/numbers in a GET expecting types — the server coerces. In a **POST body**,
  send real types (`"requestLiveCoSign": true`, not `"true"`).
- **List rows are keyed `id`, not `objectId`.** Anything returned by a `list*` endpoint uses `id`;
  create/get responses still use `objectId`. This bites when you reuse a model class for both.
- **`confirmProcedure` is PUT**, not POST. `markAsRead` and `markAllAsRead` are PUT too.
  `registerDevice`, `unregisterDevice`, `coSignProcedure`, `requestConfirmation`, `createProcedure`
  are POST. `listMyDevices`, `listProcedures`, `listPendingForSupervisor`, `getCoSignContext`,
  `getUnreadCount` are GET.
- **Paging:** `limit`, `skip`, and `withCount`. A list returns a **bare array** normally, but
  `{"results": [...], "count": N}` when `withCount=true` — `count` is the server-side total across
  all pages, not the page length. Handle both shapes.
- **Dates** come back as `{"__type":"Date","iso":"..."}` on raw objects and as plain ISO strings in
  some mapped rows. Parse defensively.
- **The co-sign code is shown once.** No endpoint returns it again. If the app loses it, the student
  must wait for the window to lapse and use `requestConfirmation`.

### Offline sync

`syncOfflineProcedures` (POST) uploads a batch logged while offline:

```json
{
  "procedures": [
    {
      "procedureTypeId": "aB3xY9kLmN",
      "hospitalId": "7lagecHXDB",
      "procedureDate": "2026-08-17T11:00:00.000Z",
      "patientName": "خالد اليوسف",
      "supervisorId": "5D4NGPq941",
      "notes": "optional"
    }
  ]
}
```

Required per item: `procedureTypeId`, `hospitalId`, `procedureDate`, `patientName`.
`supervisorId` and `notes` are optional.

```json
{
  "successCount": 1,
  "failureCount": 1,
  "results": [
    {"index": 0, "success": true,  "procedure": { "...": "..." }},
    {"index": 1, "success": false, "error": "Hospital not found"}
  ]
}
```

It is **partial-success**: each item succeeds or fails independently, and `index` maps back to your
input array — so retry only the failures, and never resend the whole batch blindly.

Two limitations to design around: this endpoint does **not** accept `procedureTypeIds` (no
multi-type sessions offline — send one item per type, and they will not share a `sessionId`), and it
does not support the live co-sign flow. Every synced row is stamped `isOffline: true`, and the
server records its own `loggedAt`, so a late upload is visible as a delayed entry and scores lower
than a live one. Sync early.
