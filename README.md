# Food After Hours

A full-stack food-redistribution **demonstration prototype** with a Next.js web app, a native SwiftUI iOS companion, and a standalone static browser demo. Dining staff can post sample surplus listings; pantry volunteers and students can preview reservations; staff can confirm simulated pickups. Student prices are a **demo 50% discount**—no payment is processed.

> **Not a real food service.** Listings, reservations, prices, partner sites, and outcomes are fictional. Real campus dining-center names are used only as example locations; no pickup desk, food-safety certification, institutional endorsement, or official partnership is implied. This project is not affiliated with or operated by any university.

## What is in this repository?

| Component | Location | What it does |
|---|---|---|
| Full-stack website | `src/` | Next.js pages and API routes backed by a local SQLite database |
| iOS app | [`ios/`](ios/README.md) | Native SwiftUI client of the full-stack API; defaults to the Student Browse preview and follows device light/dark mode |
| Static demo | `cloudflare/index.html` | Single-file, browser-only preview using local browser storage; **not** a backend for the iOS app |
| Tests | `src/lib/*.test.ts`, `e2e/` | Unit/database tests and browser end-to-end tests |
| Additional documentation | `docs/` | Architecture, feature catalog, demo script, and project notes |

## Run the full-stack website locally

**Requirements:** Node.js 26 (tested; the app uses the built-in `node:sqlite` module) and npm 10+.

```bash
npm ci
npm run dev
```

Open `http://localhost:3000`. On first access, the database initializes with sample records in `data/osufood.sqlite`. Set `DATABASE_PATH` to a `.sqlite` file **inside this repository** to change its location; `.env.example` shows the default. Optional `npm run seed` resets local demo data to fictional samples, so don't run it if you want to keep local changes.

For a production-mode local build, run `npm run build` followed by `npm run start`. A deployed full-stack site needs a Node.js runtime, writable persistent SQLite storage, and the `/api/state` and `/api/action` endpoints; uploading static files alone will not run the API.

### Preview roles and demo flow

The **Preview as** menu changes the UI context; it is **not authentication**. Use Student to browse sample half-price food and view demo orders, Pantry Volunteer to reserve quantities for a fictional site, Dining Staff to create listings and confirm pickup codes, and Administrator to see activity and reset the database.

One walkthrough: switch to Dining Staff and create a listing with a future pickup window → switch to Pantry Volunteer or Student and reserve it → copy the pickup code → switch back to Dining Staff and confirm pickup → view Impact. The administrator reset discards all current demo changes. See [`docs/DEMO_SCRIPT.md`](docs/DEMO_SCRIPT.md) for a longer walkthrough.

### iOS companion

Open [`ios/OSUFood.xcodeproj`](ios/OSUFood.xcodeproj) in Xcode (iOS 18+ target). The app starts on **Student Browse**, offers the same preview roles, and uses an orange-and-black palette in both device appearance modes. The API URL is an inert `https://example.com` placeholder for privacy: set it to your own reachable **full-stack HTTPS API** before running, not to `cloudflare/index.html`. See [`ios/README.md`](ios/README.md) for endpoint setup, simulator/device instructions, and code-signing notes. No local Node server is required when configured for a reachable hosted API.

### Standalone static demo

Open or host `cloudflare/index.html` for a self-contained browser preview. Its data lives in each browser's local storage; it does not share the SQLite database or provide the API, and it does not include the student-ordering flow.

## Commands

| Command | Purpose |
|---|---|
| `npm run dev` | Start the Next.js development server |
| `npm run build` / `npm run start` | Build and serve the full-stack site |
| `npm run seed` | Replace local SQLite data with fictional sample records |
| `npm run typecheck` | Check TypeScript types |
| `npm run lint` | Run ESLint |
| `npm test` | Run Vitest unit and database tests |
| `npm run test:e2e` | Run Playwright browser tests (requires a built site and installed browser binaries) |

## Safety and deployment boundaries

**Do not deploy this full-stack API publicly as a real service.** There is no user authentication, authorization, or role enforcement: any API caller can read all reservation codes and invoke mutation endpoints, including reset. A UI confirmation does not secure the API. The database must contain **fictional data only**. Before any real pilot, add server-side identity, scoped reads, authorization, safe pickup verification, appropriate food-handling policies, and privacy controls. An access-controlled demo is safer than an unrestricted public deployment, but role previews still do not grant security.

The SQLite file in `data/`, installed packages in `node_modules/`, Next.js output in `.next/`, test output, local environment files, and Xcode user settings should remain local and are Git-ignored. `node_modules/` and `.next/` are recreated by installing/building; `data/` contains mutable demo state and should not be published. The source-controlled files are a small subset of the files you see locally.

## Further reading

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — components, storage, and reservation transaction rules
- [`docs/APP_FEATURES.md`](docs/APP_FEATURES.md) — UI features and routes
- [`docs/TEST_RESULTS.md`](docs/TEST_RESULTS.md) — recorded test results
- [`docs/AI_USE_LOG.md`](docs/AI_USE_LOG.md) — AI-assistance disclosure
- [`ios/README.md`](ios/README.md) — iOS setup and prototype security boundaries
