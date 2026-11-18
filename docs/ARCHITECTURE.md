# System Architecture — OSU Food *After Hours*

```mermaid
flowchart TD
  subgraph Client [Client Viewports - Desktop & Mobile]
    A[Browser / Cloudflare Tunnel / Localhost:3000]
    B[Route Pages: /browse, /listing/:id, /staff, etc.]
    A --> B
  end

  subgraph NextJS [Next.js App Router Application]
    B --> C[Interactive Client Core: src/components/app.tsx]
    C -->|GET snapshot| D[/api/state]
    C -->|POST action: reserve, complete, etc.| E[/api/action]
    E --> F[Zod Validation & Business Rules: src/lib/domain.ts]
    D --> G[Database Access Layer: src/lib/db.ts]
    F --> G
  end

  subgraph Storage [Persistence Layer]
    G -->|WAL Journal Mode & BEGIN IMMEDIATE| H[(data/osufood.sqlite)]
  end
```

---

## Component Breakdown

1. **Presentation Layer (Next.js 16 + React 19):**
   - Individual page routes (`/browse`, `/listing/[id]`, `/reservations`, `/staff`, `/create`, `/pickups`, `/impact`, `/admin`, `/guide`) providing deep-linking and browser navigation support.
   - Shared responsive UI component in `src/components/app.tsx` styled with Tailwind CSS 4 using OSU heritage colors (orange, deep charcoal, warm neutral panels).
   - Dynamic URL state synchronization managed via `src/lib/routes.ts`.

2. **Validation & Business Logic Layer (`src/lib/domain.ts`):**
   - Zod schemas enforcing strict input constraints: positive whole numbers for quantities, valid ISO-8601 timestamps, and pickup end times strictly in the future and after pickup start.
   - Pure domain functions calculating derived listing statuses (`AVAILABLE`, `PARTIALLY_RESERVED`, `FULLY_RESERVED`, `CLOSED`, `EXPIRED`) and verifying cancellation/completion eligibility.

3. **Data Access & Transaction Layer (`src/lib/db.ts`):**
   - Synchronous local SQLite driver using Node.js built-in `node:sqlite`.
   - `BEGIN IMMEDIATE` transaction blocks serializing concurrent reservation mutations to guarantee zero overbooking and non-negative inventory.
   - Schema enforcement via SQLite `CHECK` constraints on available quantities and positive reservation amounts.

---

## Primary Entities

| Entity | Primary Fields | Key Relationships |
|---|---|---|
| `organizations` | `id`, `name`, `type`, `description`, `location`, `createdAt` | Types: `DINING_FACILITY` (McNary, Arnold, Marketplace West), `FOOD_PANTRY`, `REDISTRIBUTION_PARTNER`. |
| `listings` | `id`, `organizationId`, `title`, `description`, `category`, `quantityAvailable`, `originalQuantity`, `quantityUnit`, `pickupLocation`, `pickupStart`, `pickupEnd`, `storageRequirements`, `allergenInformation`, `closed`, `createdAt`, `updatedAt` | Foreign key to `organizations(id)`. Quantity must remain `>= 0`. |
| `reservations` | `id`, `listingId`, `organizationId`, `quantity`, `status`, `pickupCode`, `createdAt`, `confirmedAt`, `collectedAt`, `canceledAt` | Foreign keys to `listings(id)` and `organizations(id)`. Status in `('RESERVED','COMPLETED','CANCELED')`. |
| `activity` | `id`, `action`, `entityType`, `entityId`, `description`, `timestamp` | Append-only system audit log. |

---

## Reservation & Inventory Lifecycle

```
[Listing Created (e.g. 20 boxes)]
         │
         ▼
[Pantry Reserve (e.g. 5 boxes)] ──(Atomic Transaction)──> [Available drops to 15; 6-digit Code Generated]
         │
         ├───────────────────────────────────────────────┐
         │                                               │
(Volunteer arrives with code)               (Cancellation before end window)
         ▼                                               ▼
[Staff verifies code in /pickups]               [Reservation marked CANCELED]
         │                                               │
         ▼                                               ▼
[Reservation marked COMPLETED]                  [5 boxes returned to inventory]
[Confirmed & Collected timestamps set]          [Available restored to 20]
[Impact metrics incremented]
```

---

## Deployment & Execution Modes

1. **Full-Stack Local & Tunnel Deployment (Primary):**
   - Runs `next dev` or `next start` on `localhost:3000`.
   - Exposing via Cloudflare Tunnel (`cloudflared`) connects the remote hostname directly to `localhost:3000`, enabling live API calls against SQLite.
2. **Standalone Browser Demo (`cloudflare/index.html`):**
   - Independent single-file HTML/CSS/JS prototype with client-side localStorage simulation.
   - Suitable for zero-backend static environments (such as static Cloudflare Pages without Node.js).
