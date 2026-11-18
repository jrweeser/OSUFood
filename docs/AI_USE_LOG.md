# AI Use Disclosure & Verification Log — OSU Food *After Hours*

*AI-assistance disclosure for this academic demonstration prototype.*

---

## 1. AI Tools & Models Employed
- **Autonomous Coding Agent:** Claude Code CLI & DeepMind Agent Harness
- **LLM Reasoning & Generation:** `antigravity/gemini-3.8-flash-high` and `cx/gpt-6-sol`
- **Search & Verification Capabilities:** Authenticated web search and fetch tools targeting official Oregon State University documentation (`uhds.oregonstate.edu`).

---

## 2. Scope of AI-Generated Components

| Component | Nature of AI Contribution | Verification Method |
|---|---|---|
| **Architecture & Database** | Schema definition, SQLite `node:sqlite` transaction logic, and seed data generators. | Unit and concurrency integration tests (`src/lib/db.test.ts`), manual schema inspection. |
| **User Interface & Routing** | Next.js 16 App Router pages, Tailwind CSS responsive layouts, and interactive state management. | Automated Playwright browser tests (`e2e/workflow.spec.ts`) across desktop and mobile viewports. |
| **Dining Research** | Official retrieval of OSU Corvallis dining centers (McNary, Arnold, Marketplace West). | Direct citation and fact-checking against official UHDS web pages (`uhds.oregonstate.edu/all-stories/explore-campus-dining`). |
| **Project Documentation** | Draft technical patent notes, demo script, business plan assumptions, and architecture diagrams. | Reviewed against project scope; disclaimers added stating claims are hypothetical exercises. |

---

## 3. Automated Verification Executed by the Assistant

The following programmatic quality checks were executed and confirmed passing in the local environment:
- **TypeScript Static Analysis:** `npm run typecheck` (`tsc --noEmit`) — Zero type errors.
- **Linting & Code Quality:** `npm run lint` (`eslint .`) — Zero warnings, zero errors.
- **Unit & Integration Suite:** `npm test` (`vitest run`) — 11/11 tests passed.
- **End-to-End Automation:** `npm run test:e2e` (`playwright test`) — 14/14 tests passed across Chromium Desktop and iPhone 13 Mobile profiles.
- **Production Build:** `npm run build` (`next build` with Turbopack) — Zero compilation warnings or errors.
- **Security Audit:** `npm audit --omit=dev --json` — Zero production vulnerabilities.

---

## 4. Human Verification & Peer Review Responsibilities

Human reviewers should conduct the following evaluations before any presentation or pilot:
1. **Live Usability Testing:** Rehearse the 90-second demo script with a human speaker to verify pacing and narrative flow.
2. **Business Plan Alignment:** Review financial assumptions, pilot metrics, and operational feasibility against team goals.
3. **Patent Claim Review:** Confirm the practice claims reflect the intended scope of the exercise.
4. **Food Safety Oversight:** Validate that prototype handling instructions align with institutional guidelines and state food-safety standards.
