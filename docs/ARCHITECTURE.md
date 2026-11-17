# Architecture

Next.js 16.4.6 App Router, React 19.3.1, TypeScript, Tailwind 4.3.5, Lucide 1.74, Zod 4.6.7, Node 26 built-in SQLite. SQLite avoids a separate native dependency and Prisma's compatibility surface for this local demo.

```mermaid
flowchart LR
  A[Desktop/mobile browser] --> B[Route pages + React UI: src/components/app.tsx]
  B -->|GET snapshot| C[/api/state]
  B -->|POST actions| D[/api/action]
  C --> E[src/lib/db.ts]
  D --> F[src/lib/domain.ts: Zod/rules]
  D --> E
  E --> G[(data/osufood.sqlite)]
```

App Router page files now expose `/browse`, `/listing/[id]`, `/reservations`, `/staff`, `/create`, `/pickups`, `/impact`, `/admin`, and `/guide`. The shared client UI in `src/components/app.tsx` reflects navigation in browser history, while `src/lib/routes.ts` maps view names to paths. Reloading a route still fetches state from `/api/state`.

Data entities: organizations, listings, reservations, activity. The SQLite schema is created on first access inside `src/lib/db.ts`; seed timestamps are relative to startup/seed time and IDs are predictable for examples. Runtime DB files reside under `data/`, not `public/`. Opening an existing database adds missing fictional campus-site organization rows with `INSERT OR IGNORE`, retaining existing listings and reservations; an explicit reset still deletes table rows and reseeds. Reset does not remove arbitrary files.

**Role simulation**: the header chooses staff, pantry, or admin and one fictional organization. Added campus-site choices use named campus areas only as illustrative locations; they do not imply a real pantry service or partnership. API requests contain organization identifiers; server verifies organization type and, for editing/closing/completing, listing ownership. This is consistency logic, **not an authorization boundary**—a direct caller can impersonate an organization and invoke reset. Add real identity, session, RBAC, CSRF mitigation, authorization checks and rate limiting before any deployment.

**Reservation lifecycle**: `RESERVED → COMPLETED` when staff enter matching code; `RESERVED → CANCELED` when before pickup end. Completion is immutable and cannot repeat. On cancellation, quantity returns only if listing is not closed. Listing status is derived on read from available quantity, closed flag and pickup end: AVAILABLE, PARTIALLY_RESERVED, FULLY_RESERVED, CLOSED, EXPIRED. Expired listings cannot be reserved. SQLite `BEGIN IMMEDIATE` ensures serialized read-modify-write on the local DB; `CHECK` prevents negative availability and nonpositive stored reservation quantities. One Node server and local file are intended; multi-host use is out of scope.

**Analytics**: completed pickups count only COMPLETED rows; quantity totals group by actual unit; charts use completed pickups by day/category and derived listing statuses. Completion rate = completed / (completed + still reserved), excluding canceled. Seeded sample completion dates are synthetic, not evidence of real redistribution.

**Deployment considerations**: demo only on localhost. SQLite file needs a writable project directory. Not suitable for public deployment; food-safety policies, identity verification, operational partnerships, compliance, backups, monitoring, and secure code distribution must precede any pilot. No food-safety certification occurs in the app.
