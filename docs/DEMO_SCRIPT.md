# 90-second demo script

Before recording: `npm run seed`, `npm run dev`, open http://localhost:3000. Or choose Administrator → Demo controls → Reset demo data and accept confirmation. Note initial completed pickups **5** and completed **boxes 0**. Fictional demo organizations only.

| Time | Action and expected UI | Expected database change | Narration |
|---|---|---|---|
| 0–20s | Select **Dining Staff**, North Campus Dining, **Create Food Listing**. Enter “Fresh Produce Boxes,” description “Fresh produce for community partners,” category Produce, 20 boxes, “North Campus Dining pickup desk,” and future start/end (defaults are future). Publish. Confirmation appears. | One listing inserted, 20 boxes available; CREATE log. | “Dining staff can expose surplus in seconds.” |
| 20–40s | Switch to **Pantry Volunteer**, Campus Community Pantry; search “Fresh Produce Boxes,” open details, reserve **5**. Confirmation includes reservation ID, pickup code and **15 boxes remain**. | Reservation RESERVED for 5; inventory 20 → 15, RESERVE log. | “The pantry sees real availability and reserves just what it can pick up.” |
| 40–55s | In **My reservations**, read ID, pickup window and six-digit pickup code. Browse again to check **15 boxes available**. | No change. | “The pickup details stay visible, even after a reload.” |
| 55–75s | Switch to **Dining Staff** → **Pickups**. Find Fresh Produce Boxes, enter its code and click **Confirm pickup**. | Reservation COMPLETED; confirmedAt and collectedAt stored; COMPLETE log. | “Dining staff marks actual collection—only once.” |
| 75–90s | Open **Impact**; completed pickups increase **5 → 6**, redistributed boxes **0 → 5**, with other units kept separate. | Derived analytics; no extra mutation. | “The dashboard measures completed handoffs, not just promises.” |

Recovery: if a record already exists, reset via Administrator → Demo controls (this deletes the current demo records). If the code is lost, switch to Pantry Volunteer → My reservations to retrieve it. If a form is blocked, fill the required description/location and choose an end later than the start and in the future. If internet is unavailable after setup, use the local seeded app; no external login is needed. No prerecorded video was produced. Desktop/mobile screenshots from automated testing are in `docs/screenshots/`.
