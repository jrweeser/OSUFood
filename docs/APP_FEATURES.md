# Implemented features

| Feature | UI location | Behavior |
|---|---|---|
| Introduction and simulated role entry | Landing page `/` | Explains problem, 3-step process, live-from-local-db sample metrics, three available fictional food cards with pickup windows and clickable details, and disclaimers. |
| Facility overview and listing search | Dining Staff → Overview | Active/pending/completed counts and own listings. |
| Create/edit/close listings | Dining Staff → Create listing; Overview → Edit/Close | Server validates required values and date/quantity constraints. |
| Browse/search/filter and campus-site choices | Pantry Volunteer → Browse food | Category, source, pickup availability, text; soonest end first. Additional fictional pantry-site options for Memorial Union, Valley Library and residence hall area preserve legacy choices and reservations. |
| Listing details and partial reservation | Browse food → View details | Organization-supplied handling/allergen information, quantity, confirmation, prominent From/Until pickup window. |
| Reservation groups and cancellation | Pantry Volunteer → My reservations | Upcoming/completed/canceled; cancel eligible active pickup. |
| Pickup code confirmation | Dining Staff → Pickups | Shows pantry organization and records one-time collection. |
| Impact analytics | Any role → Impact | Completed counts, unit-separated totals, date/category/status visualizations, accessible data tables. |
| Reset and activity | Administrator → Demo controls | Confirmed reset of only local demo records; recent activity. |
| Guided demo | Any role → Demo guide | Written on-screen walkthrough. |

Screenshots generated from passing Playwright browser tests: [desktop browse](screenshots/desktop-browse.png), [mobile browse](screenshots/mobile-browse.png), [desktop Impact](screenshots/desktop-impact.png) and [mobile Impact](screenshots/mobile-impact.png). Browse screenshots show the revised OSU-inspired orange/charcoal palette and prominent, separately labeled pickup dates and times. Reserve additional screenshots here after human review: landing [ ], listing detail [ ], pantry reservations [ ], staff pickup [ ].

Limitations: simulation accounts are not secure authentication, and server-side organization checks verify type/ownership against a client-supplied identifier only. No external notifications or food-safety approval.
