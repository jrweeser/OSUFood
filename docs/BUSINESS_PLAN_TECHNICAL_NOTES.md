# Business-plan technical notes

**Target users (hypothetical):** dining teams with surplus food; authorized pantry and redistribution volunteers; administrators coordinating a pilot. The named organizations in the demo are fictional examples, **not partners**.

**Core value proposition:** a single view of availability, pickup windows and reservations, reducing coordination friction and making completed handoffs measurable. The software provides listing, filtered discovery, partial reservation, cancellation, pickup-code confirmation and analytics separated by food unit.

**Cost assumptions, not quotes:** the prototype runs on an existing laptop with free/open-source tools and no paid APIs. A real pilot would require hosting, persistent storage/backups, maintenance, security and identity verification, staff training, and legal/food-safety support. No specific dollar figure is verified.

**Proposed impact measures (future controlled pilot):** record timestamps for each coordination step, compare average time from food availability to a confirmed pickup against the existing coordination method on comparable shifts; track quantity redistributed by standardized unit or separately by unit, completed-reservation rate, percentage of listings with a collection, and cancellation rate. Proposed **50% reduction in coordination time** is a target, not an observed finding. Collect baseline and pilot samples with consistent definitions, account for different food types and pickup windows, and report sample sizes and uncertainty. Do not treat synthetic seed metrics as research results.

**Potential partner categories, not commitments:** campus dining operations, approved food pantries, local redistribution networks, food-safety advisers. Future improvements: actual authentication, signed organization onboarding, notifications, documented food-handling workflow, accessibility study, structured pickup scheduling, audit trail, production backups. Technical limitations: demo roles can be impersonated; SQLite is local-only; no real food-safety or legal compliance assessment.
