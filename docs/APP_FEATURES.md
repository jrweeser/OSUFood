# Implemented Application Features — OSU Food *After Hours*

| Feature | Primary URL & Location | Key Capabilities & Verification |
|---|---|---|
| **Landing & Concept Overview** | `/` (Home) | Introduces the problem statement, 3-step redistribution process, real-time live database metrics, and top 3 available listings with direct detail links. |
| **"Preview as" Role Switcher** | Global Header (All pages) | Allows testers and presenters to toggle between Student, Pantry Volunteer, Dining Staff, and Administrator previews without authentication. |
| **Student Demo Ordering** | `/student`, `/student/listing/:id`, `/student/reservations` | Student preview browses dining-center listings, sees 50% off staff-entered original per-unit price, reserves quantity, and receives a code and saved demo total. No payment processing or automated readiness alert. |
| **Surplus Food Discovery** | `/browse` (Pantry Volunteer) | Interactive search and filtering by food category (*Produce, Prepared meals, Bakery, Dairy, Packaged*), source dining facility (*McNary, Arnold, Marketplace West*), and pickup urgency (Next 24 hours vs Later). Deterministically sorted by earliest pickup deadline. |
| **Listing Details & Reservation** | `/listing/:id` | Full listing specification with organization-supplied allergen and storage guidance, prominent From/Until pickup window callout, interactive quantity selector, and server-side atomic reservation. |
| **Commitments & Pickup Codes** | `/reservations` (Pantry Volunteer) | Categorized list of upcoming, completed, and canceled reservations showing unique 6-digit pickup verification codes, pickup windows, and instant self-service cancellation that restores listing availability. |
| **Dining Operations Dashboard** | `/staff` (Dining Staff) | Overview of active listings, pending collections, completed handoffs, and facility activity log for McNary, Arnold, or Marketplace West. |
| **Surplus Creation & Editing** | `/create` (Dining Staff) | Validated form enforces positive quantities, original per-unit price, dining-center pickup location dropdown, staff-set pickup window and instructions, handling details, and allergen disclosures. |
| **Pickup Code Verification** | `/pickups` (Dining Staff) | Lists reservations awaiting collection. Staff input the volunteer's 6-digit pickup code to confirm handoff. Rejects invalid codes and enforces one-time completion. |
| **Impact Analytics Dashboard** | `/impact` (All roles) | Visualizes verified data: total pickups completed, active listings, unit-separated quantities (boxes, portions, items, bags, trays), completed pickups by day, and category breakdown. Includes accessible data tables. |
| **Administrator Controls & Reset** | `/admin` (Administrator) | System-wide statistics, live 30-entry audit activity log, and protected two-step database reset to restore the initial classroom seed data. |
| **Interactive Demo Guide** | `/guide` (All roles) | Built-in step-by-step checklist guiding evaluators through the complete 90-second listing → reservation → confirmation cycle. |

---

## Visual Verification & Captured Screenshots

Automated Playwright test runs capture full-page screenshots during testing:
- **Desktop Browse View:** [`docs/screenshots/desktop-browse.png`](screenshots/desktop-browse.png)
- **Mobile Browse View (iPhone 13):** [`docs/screenshots/mobile-browse.png`](screenshots/mobile-browse.png)
- **Desktop Impact Dashboard:** [`docs/screenshots/desktop-impact.png`](screenshots/desktop-impact.png)
- **Mobile Impact Dashboard:** [`docs/screenshots/mobile-impact.png`](screenshots/mobile-impact.png)

---

## Prototype Boundaries

- **Role Switching:** The "Preview as" dropdown is an unauthenticated presentation feature. It does not provide cryptographic identity verification or session-based access control.
- **Data Isolation:** Full-stack operations target the local project database at `data/osufood.sqlite`; the separate static demo uses browser storage and has no student flow.
- **Locations & Payments:** Dining-center names are real, but exact pickup points, prices, orders, and pickup service are fictional; no payments are collected.
- **Food Safety:** The application acts as a logistical coordination tool; it does not inspect, test, or certify the safety of food items.
