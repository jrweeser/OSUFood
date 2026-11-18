# 90-Second Demonstration Script — OSU Food *After Hours*

## Preparation
- Start the server: `npm run dev` (or `npm run start`)
- Open: `http://localhost:3000` (or your Cloudflare tunnel link)
- Baseline State: Select **Preview as: Administrator** → Navigate to **Demo controls** (`/admin`) → Click **Reset demo data**.
- Initial Baseline Metrics: Completed pickups: **5**, completed boxes: **0** (fictional sample baseline).

---

## Timed Walkthrough

| Time | Action & Expected Interface | Database State Change | Suggested Narration |
|---|---|---|---|
| **00:00 – 00:20** | In header, switch **Preview as** to **Dining Staff** (`/staff`). Select **McNary Dining Center**, click **Create Food Listing** (`/create`). Enter `Fresh Produce Boxes`, category *Produce*, quantity `20 boxes`, location `McNary Dining Center pickup desk`, and a valid future window. Click **Publish listing**. | 1 listing record inserted into SQLite; 20 boxes available; `CREATE` action logged in `activity`. | *"When campus dining centers like McNary have extra portions at closing, staff can list them in under twenty seconds with clear storage and pickup windows."* |
| **00:20 – 00:40** | Switch **Preview as** to **Pantry Volunteer** (`/browse`). Select **Campus Community Pantry — Memorial Union**. Filter or search `Fresh Produce Boxes`. Click **View details** (`/listing/:id`), select **5 boxes**, and click **Reserve food**. Confirmation displays reservation ID, pickup code, and notes **15 boxes remain**. | Reservation record created in `RESERVED` status; available listing inventory transactionally decremented from 20 to 15; `RESERVE` action logged. | *"Pantry volunteers can instantly discover verified surplus across campus, reserving only what they can transport. The system locks in five boxes atomically."* |
| **00:40 – 00:55** | Go to **My reservations** (`/reservations`). Observe upcoming reservation showing pickup window and 6-digit pickup code. Click **Browse food** to confirm inventory shows `15 boxes available`. Reload the page to demonstrate persistence. | No state mutation; confirms data persists across client refreshes and sessions. | *"Volunteers get an immutable pickup code. Refreshing the browser or switching devices preserves the reservation."* |
| **00:55 – 00:75** | Switch back to **Dining Staff** → **Pickups** (`/pickups`). Under pending pickups for McNary Dining Center, locate `Fresh Produce Boxes`. Enter the volunteer's 6-digit pickup code and click **Confirm pickup**. | Reservation status updated to `COMPLETED`; timestamps recorded for `confirmedAt` and `collectedAt`; `COMPLETE` logged. Listing inventory remains 15. | *"When the volunteer arrives, dining staff enter the pickup code to confirm the physical handoff. Duplicate confirmations and invalid codes are automatically rejected."* |
| **00:75 – 00:90** | Navigate to **Impact** (`/impact`). Note that platform-wide completed pickups have increased from **5 to 6**, and redistributed boxes have updated from **0 to 5 boxes**, with all distinct units preserved independently. | Analytics recomputed from completed database records; category and daily redistribution charts update immediately. | *"The platform closes the loop with verifiable metrics—showing exactly what was saved and where it went, without guessing or conflating units."* |

---

## Recovery & Troubleshooting

1. **Stale or unexpected data:** Switch to **Administrator** (`/admin`) and click **Reset demo data** to wipe current session state and reload the deterministic seed.
2. **Lost pickup code:** Switch to **Pantry Volunteer** → **My reservations** (`/reservations`) to retrieve the 6-digit code for any active reservation.
3. **Form validation rejection:** Ensure the quantity is a positive whole number, and the pickup end time is set after the start time and in the future.
4. **Offline access:** The Next.js application runs 100% locally against SQLite with zero cloud dependencies after setup.

Screenshots of the desktop and mobile interface are cataloged in [`docs/screenshots/`](screenshots/).
