# OSU Food After Hours

**Good food. Better connections. Less waste.** A local academic prototype for coordinating surplus dining food with fictional pantry organizations. Not affiliated with or operated by Oregon State University.

## Requirements

- Node.js 26+ (uses built-in `node:sqlite`; tested on 26.13.0), npm 11+.
- Internet during initial `npm install` and optional Playwright browser installation; afterward the app needs no cloud service.

## Quick start

```sh
npm install
npm run seed
npm run dev
```

Open http://localhost:3000. If port 3000 is occupied, Next.js prints the selected port. Database defaults to `data/osufood.sqlite`. `.env.example` documents optional `DATABASE_PATH` (must point to a `.sqlite` file inside the project). The app creates and seeds a missing database automatically. `npm run seed` resets only this app's demo database; it replaces current demo records. Never point it at a database you wish to preserve. `data/` is ignored by Git and not publicly served.

## Cloudflare Tunnel: local app on port 3000

This machine has a `cloudflared` tunnel connector and a Next.js development server listening at **localhost:3000**. The tunnel targets that server, **not** `cloudflare/index.html`. The real app needs the server running and `/api/state` and `/api/action` reachable through the same tunnel. Its views now have actual paths: `/browse`, `/listing/{id}`, `/reservations`, `/staff`, `/create`, `/pickups`, `/impact`, `/admin` and `/guide`. A copied `/browse` or listing link can be opened directly and refreshed. On localhost, the main routes and `/api/state` returned HTTP 200; test the Cloudflare hostname itself before relying on the demo.

**Important:** The tunnel makes the local demo publicly reachable if the route is public. Header role selection is not authentication, and the API accepts client-supplied organization identifiers, including a reset action. Do not put this app on a public domain without Cloudflare Access or real authentication and authorization. If Access protects the hostname, allow the actual testers only. The standalone `cloudflare/index.html` is an alternative for an entirely static Pages upload; it is **not used by this tunnel** and stores reservations only in each visitor's browser.


## Commands

| Command | Purpose |
|---|---|
| `npm run dev` | Development server |
| `npm run build` / `npm run start` | Build / run production server |
| `npm run seed` | Reset to deterministic relative-date sample records |
| `npm run typecheck` | TypeScript check |
| `npm run lint` | ESLint |
| `npm test` | Vitest unit + SQLite integration tests, separate `data/osufood-test.sqlite` |
| `npx playwright install chromium` | Install local browser once |
| `npm run test:e2e` | Desktop + mobile Chromium journeys, separate `data/osufood-e2e.sqlite` |

## Product tour

- **Landing page**: Shows three real, fictional seeded listings with pickup windows and clickable View details buttons; hero shows sample listing and completed-pickup counts.
- **Dining Staff**: Overview → Create Food Listing → edit/close own listings → Pickups to enter code and complete pickup.
- **Pantry Volunteer**: Browse food with search/category/source/time filters and clearly separated pickup dates/times → choose a fictional campus-site pantry or partner → View details → reserve quantities → My reservations to review code and cancel. Memorial Union, Valley Library and residence hall area are illustrative campus areas, not verified pickup services.
- **Administrator**: Demo controls → activity log and confirmed demo reset.
- **Impact**: recorded completed pickups, unit-separated quantities and charts; seeded examples are not real-world impact.
- **Demo guide**: a five-step script directly in the interface.

Start the local server and wait for the listing count to appear; the page initially shows a loading message while fetching the SQLite-backed demo. Buttons update the view and address bar without a full reload; each main view has a direct URL. Choose **Preview as** in the header (desktop and mobile) to switch between staff, pantry and admin demo views. This is not a login or secure authentication. Choosing a facility or pantry within the role is also a simulation. **Do not expose the app on a public network.**

## 90-second demonstration

Reset via Administrator → Demo controls, then select Dining Staff / North Campus Dining. Create “Fresh Produce Boxes,” 20 boxes, future pickup window, North Campus Dining pickup desk. Switch to Pantry Volunteer / Campus Community Pantry, search for it, reserve five boxes and note the six-digit pickup code. Confirm 15 remain; switch back to staff → Pickups, enter the code and confirm. Impact: completed pickups 5 → 6, boxes 0 → 5. Full sequence and recovery in [docs/DEMO_SCRIPT.md](docs/DEMO_SCRIPT.md).

## Architecture

Next.js 16 App Router + React 19 + TypeScript + Tailwind 4, Zod 4 for server validation, and Node's built-in SQLite. Client UI sends changes to `/api/action`, which invokes domain rules and synchronous `BEGIN IMMEDIATE` SQLite transactions; `/api/state` returns derived listing status and analytics. Built-in SQLite was chosen over Prisma to avoid ORM/native-addon compatibility and keep this Node 26 demo small. No managed services required. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Prototype limitations

No real identities, secure authorization, food-safety checks, official partner verification, notifications, audit-grade identity trails, or production concurrency across hosts. Anyone who can send HTTP requests to this local app can claim an organization and invoke the demo reset; never deploy it publicly without real authentication/authorization. Handling and allergen disclosures are supplied by listing organizations and not independently verified. Live inventory and status are derived from local records, but completed example reservations have artificial history. Pickup codes are shown to the volunteer and to staff in the demo; this is a demonstration aid, not a secure proof of collection. No actual pilot-study outcomes have been measured.
