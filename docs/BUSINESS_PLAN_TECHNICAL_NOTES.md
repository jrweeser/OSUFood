# Business Plan Technical Notes — OSU Food *After Hours*

*Technical documentation prepared for ENGR 110 university engineering entrepreneurship business plan authors.*

---

## 1. Target Customers & Users (Operational Personas)

1. **Supply-Side Users (Campus Dining Operations):**
   - Dining supervisors and closing shift culinary staff at campus dining centers (**McNary Dining Center**, **Arnold Dining Center**, **Marketplace West**).
   - *Operational Need:* Rapid surplus entry (under 60 seconds) without manual spreadsheets or ad-hoc phone calls at closing.
2. **Demand-Side Users (Redistribution Partners & Student Pantries):**
   - Authorized volunteers and student leaders at approved redistribution points (e.g., *Campus Community Pantry*, *Student Mutual Aid Kitchen*, and community hunger networks).
   - *Operational Need:* Transparent, immediate visibility into what food is available, in what container units, where to pick it up, and by what deadline.
3. **Institutional Administrators:**
   - University sustainability officers, campus basic needs coordinators, and dining directors.
   - *Operational Need:* Auditable handoff metrics, waste diversion totals, and reliable completion records to substantiate sustainability reporting.

*Note: All organizational names and pilot partners mentioned in the prototype are simulated demonstration entities and do not imply formal contractual agreements.*

---

## 2. Core Value Proposition & Technical Differentiation

- **Frictionless Handoff Logistics:** Eliminates telephone tag, group chat noise, and missed pickup windows through centralized real-time inventory discovery.
- **Atomic Two-Sided Coordination:** Prevents over-promising or over-booking surplus food via database-level serialization (`BEGIN IMMEDIATE`).
- **Verifiable Pickup Authentication:** Employs an automated 6-digit pickup verification code exchanged physically at collection, ensuring completed records represent actual handoffs rather than unfulfilled claims.
- **Unit-Separated Impact Analytics:** Categorizes redistributed mass by distinct units (boxes, portions, bags, trays) to prevent misleading or invalid aggregation across incompatible food types.

---

## 3. Financial & Operational Cost Model Assumptions

*These figures represent structural engineering assumptions for financial modeling, not vendor quotations.*

| Cost Category | Academic Prototype | Projected 12-Month University Pilot |
|---|---|---|
| **Software Licensing** | $0 (Open-source Next.js, SQLite, React) | $0 (Core stack remains open-source) |
| **Cloud Hosting & Infrastructure** | $0 (Localhost / free tier Cloudflare Tunnel) | ~$50 – $150 / month (Managed cloud containers, PostgreSQL/Turso DB, automatic backups) |
| **Identity & Authentication** | $0 (Role-preview simulation) | Integrated into campus SSO (SAML 2.0 / Shibboleth / Duo CAS) via existing campus agreements |
| **SMS / Push Notification Gateway** | $0 (On-screen verification) | ~$25 – $50 / month (Twilio / AWS SNS for arrival alerts) |
| **Maintenance & Support** | Student project engineering | Part-time student technician / university basic needs work-study |
| **Food Safety & Compliance Legal** | Educational prototype disclaimer | Institutional food-safety officer review, Good Samaritan Act compliance agreements |

---

## 4. Proposed Metrics for a Controlled Pilot Study

To validate the technology's effectiveness in a future empirical pilot, the following research protocol is proposed:

1. **Coordination Latency (Primary Target Metric):**
   - *Proposed Target:* Achieve a **50% reduction in the average time required to coordinate a food pickup** compared to baseline coordination methods (phone/email/text).
   - *Measurement Plan:* Compare timestamp logged from listing publication to volunteer reservation, against historical logs of staff outreach time.
2. **Fulfillment Rate:**
   - Percentage of listed surplus resulting in verified completed pickups (Target: > 85%).
3. **Cancellation & Expiration Rates:**
   - Proportion of reservations canceled prior to collection deadline, and volume of unreserved food expiring before handoff.
4. **Diversion Volume by Category:**
   - Net quantity preserved across produce, prepared meals, bakery, dairy, and packaged goods.

*Important Course Disclosure: The 50% coordination time target is a hypothetical project objective, not an empirically observed outcome.*
