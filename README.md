# OSU Food *After Hours*

> **Good food. Better connections. Less waste.**  
> A university engineering entrepreneurship prototype (ENGR 110 at Oregon State University) connecting campus dining centers with approved community food pantries to redistribute wholesome surplus food.

*Academic demonstration prototype. Not affiliated with, endorsed by, or operated by Oregon State University or University Housing & Dining Services (UHDS).*

---

## Overview

Edible surplus food is frequently discarded by campus dining facilities after service hours, while student-facing pantries and community food assistance organizations experience ongoing demand. **OSU Food *After Hours*** bridges this gap:

1. **Dining staff** post surplus food with quantities, pickup windows, and handling guidance.
2. **Pantry volunteers** browse real-time listings, filter by dining center and category, and reserve what they can redistribute.
3. **Dining staff confirm pickups** with a verification code, closing the loop and recording verifiable impact.

The platform models actual Oregon State University dining centers:
- **McNary Dining Center** (East campus)
- **Arnold Dining Center** (South campus)
- **Marketplace West** (West campus)

along with simulated student redistribution partner sites (e.g., *Campus Community Pantry — Memorial Union*, *Valley Library*, and *Residence Hall Area*).

---

## Quick Start

### Prerequisites
- **Node.js 20+** (tested on Node.js 26 with built-in `node:sqlite`)
- **npm 10+**

### Local Development
```bash
# 1. Install dependencies
npm install

# 2. Seed database with realistic relative-date records
npm run seed

# 3. Start development server
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

The database initializes automatically at `data/osufood.sqlite`. A custom database path can be specified via `DATABASE_PATH` in `.env` (see `.env.example`).

---

## "Preview as" Role Switching

To test the entire workflow without requiring an enterprise single-sign-on setup, use the **Preview as** dropdown in the top-right header:

- **Student (demo ordering):**
  - Browse available food by real dining-center name, view staff-set pickup window and instructions, and reserve at a simulated 50% discount from the entered original per-unit price.
  - See a code and saved demo total under **My orders** (`/student/reservations`). No payment is collected, no order-ready alert is sent, and no live food pickup service is implied.
- **Pantry Volunteer:**
  - Browse available surplus food (`/browse`) with live text search, category filters, and campus site selectors.
  - View detailed listing information (`/listing/:id`), select reservation quantities, and receive an instant 6-digit pickup code.
  - Review active, completed, and canceled commitments under **My reservations** (`/reservations`).
- **Dining Staff:**
  - View active listings, pending pickups, and recent facility activity (`/staff`).
  - Create new surplus listings with required quantities, original per-unit price, dining-center pickup dropdown, supervised pickup instructions, and future pickup windows (`/create`).
  - Verify incoming volunteer pickup codes and mark handoffs completed (`/pickups`).
- **Administrator:**
  - Monitor platform-wide redistribution metrics and audit activity logs (`/admin`).
  - Safely reset the demo environment back to clean sample data (`/admin`).

---

## 90-Second Demonstration Script

1. **Reset to Clean State:** In the header, select **Preview as: Administrator** → `/admin` → Click **Reset demo data**.
2. **Post Surplus (Dining Staff):**
   - Switch to **Preview as: Dining Staff** (`/staff`).
   - Select **McNary Dining Center** and click **Create Food Listing** (`/create`).
   - Enter `Fresh Produce Boxes`, 20 boxes, category *Produce*, pickup location `McNary Dining Center pickup desk`, and submit.
3. **Reserve Food (Pantry Volunteer):**
   - Switch to **Preview as: Pantry Volunteer** (`/browse`).
   - Find `Fresh Produce Boxes`, click **View details**, select **5 boxes**, and click **Reserve food**.
   - Note the **6-digit pickup code** and verify available inventory drops from 20 to 15.
4. **Confirm Collection (Dining Staff):**
   - Switch to **Preview as: Dining Staff** → **Pickups** (`/pickups`).
   - Locate the reservation for `Fresh Produce Boxes`, input the volunteer's pickup code, and click **Confirm pickup**.
5. **Verify Impact:**
   - Navigate to **Impact** (`/impact`).
   - Confirm completed pickup count increments and redistributed units update with strict unit separation.

*(See [`docs/DEMO_SCRIPT.md`](docs/DEMO_SCRIPT.md) for full speaker notes and recovery procedures.)*

---

## Deployment & Cloudflare Setup

### Running via Cloudflare Tunnel (Recommended for Live Demo)
If exposing your local instance over a Cloudflare Tunnel (e.g., via `cloudflared` connecting to `localhost:3000`):
- All routes (`/browse`, `/staff`, `/reservations`, `/impact`, etc.) and API endpoints (`/api/state`, `/api/action`) run live against the local SQLite database.
- Deep links and browser refreshes work natively through Next.js App Router routing.
- *Security Note:* Ensure your Cloudflare Tunnel is protected via Cloudflare Access so public visitors cannot trigger administrative reset actions.

### Standalone Offline HTML Demo (`cloudflare/index.html`)
For static hosting environments (such as static Cloudflare Pages with no Node.js runtime):
- Upload the `cloudflare/` directory as your static site.
- `cloudflare/index.html` is a zero-dependency, self-contained single-file HTML/CSS/JS version with client-side localStorage simulation.

---

## Available Commands

| Command | Description |
|---|---|
| `npm run dev` | Start Next.js development server on port 3000 |
| `npm run build` | Compile optimized production build with Next.js Turbopack |
| `npm run start` | Run production server |
| `npm run seed` | Seed local SQLite database with deterministic relative-date records |
| `npm run typecheck` | Run TypeScript validation (`tsc --noEmit`) |
| `npm run lint` | Run ESLint checks |
| `npm test` | Run Vitest unit & database integration test suite |
| `npm run test:e2e` | Run Playwright end-to-end tests across desktop & mobile viewports |

---

## Architecture & Technology Stack

- **Framework:** Next.js 16 (App Router) with React 19 & TypeScript
- **Styling:** Tailwind CSS 4 with Oregon State University inspired brand colors (heritage orange, deep charcoal, warm neutral panels)
- **Database:** Local SQLite utilizing Node.js built-in `node:sqlite` with `BEGIN IMMEDIATE` serialized transactions for atomic reservation bookings
- **Validation:** Zod schemas enforcing positive quantities and future pickup windows
- **Icons:** Lucide React
- **Testing:** Vitest (unit & integration) + Playwright (cross-device browser automation)

For in-depth technical documentation, see the [`docs/`](docs/) directory:
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): System architecture, schema diagrams, and transaction consistency rules
- [`docs/APP_FEATURES.md`](docs/APP_FEATURES.md): Catalog of implemented UI features and page routes
- [`docs/TEST_RESULTS.md`](docs/TEST_RESULTS.md): Course-required test verification report
- [`docs/BUSINESS_PLAN_TECHNICAL_NOTES.md`](docs/BUSINESS_PLAN_TECHNICAL_NOTES.md): Technical assumptions and pilot metrics for ENGR 110 business planning
- [`docs/PATENT_TECHNICAL_NOTES.md`](docs/PATENT_TECHNICAL_NOTES.md): Technical description and practice claims for course patent writing
- [`docs/AI_USE_LOG.md`](docs/AI_USE_LOG.md): Transparent disclosure of AI assistance and human verification steps

---

## Prototype Limitations & Food Safety

- **Not Authentication:** Role switching is a prototype demonstration tool. Production deployments require single sign-on, identity verification, and role-based access control.
- **No Food Safety Certification:** The application is an information coordination tool. Allergen and storage guidelines are organization-supplied. Actual food redistribution requires adherence to state health codes, temperature controls, and organizational liability agreements outside the app.
- **Fictional Data:** All metrics, partner names, inventory records, and prices are simulated for classroom demonstration purposes. Real dining-center names label example pickup areas, not verified desks or active services. The static `cloudflare/index.html` demo does not include student ordering.
