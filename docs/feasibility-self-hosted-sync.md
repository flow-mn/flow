# Feasibility — Self-hosted, encrypted, multi-user sync

**Status:** Assessment only (no code written)
**Reviewed against:** `analytics-overhaul` branch, app version `0.23.0+347`
**Scope of request:** Self-hosted backend + multi-device sync + conflict handling + end-to-end encryption + multi-user shared accounts with per-account permissions.

---

## 1. Verdict up front

This is **feasible but it is the single largest feature ever proposed for Flow** — it is closer to "build a second product" than "add a feature." The request bundles five things that are each substantial on their own:

1. A sync engine (change tracking + merge + conflict resolution)
2. A self-hostable backend server (Flow has **zero** backend code today)
3. End-to-end encryption with multi-device key management
4. A multi-user identity + permissions model
5. The UI for all of the above

Two of the stated requirements — **true E2E encryption** and **server-enforced per-account permissions** — are in direct technical tension (see §5). They can be reconciled, but only with real cryptographic engineering (envelope encryption + key rotation), not a CRUD backend.

My honest recommendation (§8): **do not build the full request as one project.** Ship a self-hosted *encrypted backup-sync* first (small, reuses existing code, covers the most common real-world case — your own devices and couples sharing one login), then decide whether true collaborative multi-user sync is worth the ongoing security + ops burden.

---

## 2. What Flow is today (the parts that matter here)

Grounded in the code, not assumptions:

| Area | Current state | File |
|---|---|---|
| Database | **ObjectBox** embedded NoSQL, single store, **single-user, fully offline** | `lib/objectbox.dart` |
| Backend | **None.** No auth, no API client, no server, no concept of a "user account" | — (verified: no auth/token/login code in `lib/`) |
| "Sync" today | **Whole-database JSON snapshot** + assets, zipped, uploaded to iCloud | `lib/sync/export/export_v2.dart`, `lib/services/sync/icloud_syncer.dart` |
| Sync abstraction | `Syncer` interface (`put`/`get`/`list`/`delete`/`download`) — **file-level**, only iCloud implements it | `lib/services/sync/syncer.dart` |
| Encryption | **None.** Backups are plaintext JSON in a zip | `lib/sync/export/export_v2.dart` |
| Reactive UI | ObjectBox `query().watch()` streams + singleton services with listeners | `lib/services/transactions.dart:44` |
| Identity | `Profile` and `UserPreferences` are **single global records** (one user assumed) | `lib/entity/profile.dart`, `lib/entity/user_preferences.dart` |

### The data model is *partly* sync-ready

Good news first — these help:

- **Every entity already has a `uuid` (`@Unique`)** — globally unique IDs, not just local autoincrement `id`. Essential for sync, and it's already there. (`Account`, `Category`, `Transaction`, `TransactionTag`, `FileAttachment`, `RecurringTransaction`, `Budget`, `Goal`, `Profile`, `TransactionFilterPreset`, `UserPreferences`.)
- **Relations are denormalized to UUIDs**, not just ObjectBox int links: `Transaction` carries `accountUuid`, `categoryUuid`, `tagsUuids`, `attachmentsUuids` alongside the `ToOne`/`ToMany`. This means records are portable across devices without remapping local IDs — a real head start. (`lib/entity/transaction.dart:147-225`)
- **Transactions already have soft-delete + tombstone fields**: `isDeleted`, `deletedDate`. (`lib/entity/transaction.dart:36-39`)

### The gaps that block sync

These are the parts that don't exist yet and have to be built:

1. **No `updatedDate` / version / revision on any entity.** Only `createdDate` exists. Confirmed across all entities. Without a per-record modification timestamp or logical clock, **there is no basis for conflict resolution** ("which edit wins?"). This is the #1 schema gap.
2. **Tombstones exist only for `Transaction`.** `Account`, `Category`, `TransactionTag`, `Budget`, `Goal`, etc. are **hard-deleted** (`removeAllAsync`, `box.remove`). A hard delete cannot be synced — the other device never learns it happened. Every syncable entity needs a soft-delete path.
3. **No change-log / outbox.** Nothing records "what changed locally since the last sync." Today writes just hit ObjectBox. A sync engine needs an outbox or a query over `updatedDate > lastSyncCursor`.
4. **File attachments are loose binary blobs on disk** (`FileAttachment.filePath` → file under the app data dir). These are *not* in the database and need a **separate content-addressed blob sync channel** (and separate encryption). (`lib/entity/file_attachment.dart`)
5. **Single-user assumptions baked in.** `Profile`, `UserPreferences`, and the unique constraint on `Account.name` all assume one user. Multi-user breaks several of these (e.g. two users both named "Cash"; whose `primaryCurrency`?).

---

## 3. Decomposing the request into workstreams

| # | Workstream | What it is | Net-new? |
|---|---|---|---|
| A | **Schema + write-path changes** | Add `updatedDate`/clock + tombstones to all entities; add ownership/visibility to `Account`; outbox; ObjectBox migration | Modifies every entity + every write path |
| B | **Client sync engine** | Track local changes, push/pull deltas, merge into ObjectBox, resolve conflicts, sync attachment blobs, retry/offline queue | Net-new |
| C | **Self-hostable backend** | Auth, sync API, per-account ACL, blob store, invite flow, Docker packaging, versioning, migrations | **Net-new from zero** |
| D | **E2E encryption layer** | Per-account keys, device keypairs, envelope encryption, key backup/recovery, rotation-on-revoke | Net-new, security-critical |
| E | **UI** | Server connection/sign-in, account sharing + members + roles, invites, sync status, conflict surfacing, key-recovery flow | Net-new screens |

---

## 4. Complexity ratings (you asked specifically about UI vs integration)

### Integration / backend complexity: **Very High**

- **The hard core is the sync engine + E2E, not the UI.** Conflict resolution, referential integrity across devices, blob sync, and key management are the parts that consume the time and are the ones that, if wrong, cause **silent financial-data loss or a privacy breach**. For a finance app, "mostly works" is not acceptable here.
- **There is no backend to extend** — it's greenfield. Auth, API, storage, ops, packaging, and *keeping the server versioned in lockstep with the app* is a permanent maintenance surface.
- ObjectBox is **not** natively a sync database in the open-source build. You either (a) adopt a sync-capable engine alongside/under it, or (b) hand-roll the sync protocol over the existing snapshot model. Either way this is weeks-to-months, not days.

### UI complexity: **Medium-High** (the *easier* half, and Flow's strength)

The reactive foundation is a genuine advantage: because the UI already rebuilds off ObjectBox `query().watch()` streams, **a sync engine that writes merged records into the boxes gets live UI updates for free** — no screen rewrites for "data changed remotely." New screens needed:

- Server connection / sign-in / "connect to your server"
- Account sharing: member list, role picker (read-only / read-edit), pending invites, revoke
- Invite acceptance flow (share code or link)
- Sync status (syncing / offline / conflict / last-synced)
- **Key backup & recovery** (the scary one — lose your key, lose your encrypted data; the UX must make this nearly impossible to get wrong)
- Reconciling single-user UI assumptions (per-account ownership badges, "private" vs "shared" indicators)

UI is real work but it's bounded, visual, and exactly the kind of thing this codebase does well (1 widget = 1 file, l10n via `.t()`, established theming).

---

## 5. The two tensions to resolve before any code

### Tension A — E2E encryption vs. server-enforced permissions (technical)

The request asks for **both**:
- "encrypted in a way that prevents server operators from accessing plaintext" (true E2E), **and**
- per-account permissions enforced server-side (private/shared, read-only/read-edit, invite, revoke).

These pull in opposite directions. **If the server cannot read the data, it cannot enforce "user B may only see account X"** by inspecting rows — enforcement has to be *cryptographic*: each shared account gets its own symmetric key, and that key is envelope-encrypted to the public key of every authorized member. Sharing = wrap the account key to a new member's key. **Revoking = rotate the account key** and re-wrap to the remaining members (and note: revoke can only stop *future* updates — anything already synced to a removed member's device was decryptable and can't be clawed back).

This is a solved problem (it's how E2E group messaging works), but it means workstream D is "build a small group-key-management system," not "add a permissions column." This is the part I'd want reviewed by someone with crypto experience, possibly audited.

A pragmatic middle ground: **encrypted at rest with a server-held-but-per-user key** (server *could* technically read, but the threat model is "your own server / a trusted host") gives you real privacy + clean server-side RBAC at a fraction of the complexity. Whether that satisfies "prevents server operators from accessing plaintext" depends on how literally that requirement is taken — worth confirming with the requester.

### Tension B — strategy & economics (product)

Per the current direction (free privacy-first local core; **Eny is the monetization vehicle**, pay-per-use credits; solo dev, donations currently below the Apple developer fee): a **self-hosted** sync server is the textbook feature that quietly sinks solo apps —

- It generates **support load** (every user's broken Docker deploy, reverse proxy, TLS cert, and "why won't it sync" becomes your problem).
- It is **security-critical and permanently maintained**, versioned in lockstep with the app.
- Self-hosted by definition produces **no recurring revenue**, and the request explicitly rules out paid dependencies — so it can't subsidize its own maintenance.

This isn't a reason to reject it. It's a reason to (a) scope it down hard, and (b) consider that a **hosted, optional, paid sync** could be the version that's actually sustainable, with self-hosting as a power-user option on the same protocol.

---

## 6. Architectural options

### Option B (recommended first step) — Self-hosted *encrypted backup-sync* over WebDAV/S3
Reuse what exists: `SyncModelV2` snapshot + the `Syncer` abstraction. Add (1) client-side encryption of the snapshot before upload, and (2) a `WebDavSyncer implements Syncer` (and/or S3). The requester explicitly named WebDAV as acceptable.

- **Gets you:** self-hosted ✅, user-owned data ✅, encrypted ✅, no proprietary cloud ✅, multi-device for one user ✅, couples-sharing-one-login ✅ (the most common real case).
- **Does NOT get you:** real-time sync, concurrent multi-user editing, per-account permissions, fine-grained conflict resolution (it's whole-file last-writer-wins).
- **Effort:** Small-to-medium (days-to-weeks). Mostly reuses existing code + the existing `Syncer` seam. **This is the highest value-per-effort path by far.**

### Option A — Adopt an existing local-first / CRDT sync engine
Rather than hand-roll the protocol, build on an established local-first stack (CRDT or server-authoritative log-based sync). This is the right path **if** true collaborative multi-user sync is the goal. Trade-off: most such engines are SQLite/Postgres-oriented, not ObjectBox-native, so it likely means introducing a second store or migrating the persistence layer — a large architectural change. (ObjectBox also has its own commercial Sync product with a self-hostable server, which is the most DB-native option but is paid and not E2E by default — worth evaluating against the "no paid services" requirement.)

- **Effort:** High. Multi-month. But far less risky than hand-rolling conflict resolution and crypto from scratch.

### Option C — Fully custom build (the literal request)
Workstreams A–E, all hand-built: bespoke sync protocol, custom backend, custom E2E group-key system, custom RBAC.

- **Effort:** Very high. Realistically **6–12+ months of solo work** to something trustworthy with financial data, plus indefinite maintenance. I'd advise against this as a starting point.

---

## 7. Effort summary

| Path | What you get | Rough effort (solo) | Ongoing burden |
|---|---|---|---|
| **B — encrypted backup-sync** | Self-host + multi-device (single user) + privacy | Days → few weeks | Low |
| **A — local-first engine** | Real multi-user collaborative sync | Multi-month | Medium-High |
| **C — full custom** | Exactly the request, E2E + RBAC | 6–12+ months | High (security + ops) |

---

## 8. Recommendation

1. **Phase 1 — ship Option B.** Self-hosted encrypted backup-sync via WebDAV, reusing `SyncModelV2` + the `Syncer` seam + client-side encryption. Small lift, no backend to operate, and it satisfies *most* of what real users mean by "sync across my devices / share with my partner."
2. **Decouple the schema prerequisites and do them anyway.** Adding `updatedDate` + tombstones to every entity and a soft-delete path (workstream A) is **valuable regardless** and is the foundation for any future real sync. Do this early; it's not wasted even if Phase 3 never happens.
3. **Phase 2 — measure demand** for true concurrent multi-user collaboration (private + shared accounts, live permissions). If it's genuinely there:
4. **Phase 3 — build collaborative sync on an existing engine (Option A), not from scratch**, and treat E2E + group-key management (workstream D) as a discrete, security-reviewed sub-project. Seriously weigh a **hosted, optional, paid** tier so the feature can fund its own maintenance, with self-hosting as a power-user option on the same protocol.

### Open questions for the requester (these change the estimate materially)
- Is **literal zero-knowledge** E2E required, or is "encrypted, on *your own* server, host can't casually read it" enough? (This is the single biggest cost driver — see Tension A.)
- Is the real need **multi-device for one person**, or **genuine concurrent multi-user with private accounts**? The first is Phase 1; the second is Phase 3.
- Acceptable to offer an **optional hosted** version (paid) so it's sustainable, with self-hosting as the open option?

---

*Prepared from a read of the current codebase. No application code was modified.*
</content>
</invoke>
