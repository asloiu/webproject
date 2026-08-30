# NYRA — AI Companion Platform: Master Project Spec

> **Note:** "Nyra" is a placeholder brand name — find/replace once finalized.
> Work through **phases**, not all at once. Current target: **Phase 0 — Scaffolding**.

---

## 1. Product Vision

An AI companion platform where users build an ongoing relationship with a persistent, memory-driven AI companion — differentiated from competitors (Candy.ai, Replika) by depth of continuity and premium restraint rather than volume of content or explicit material.

**Content boundary (hard constraint):** Romantic and emotionally intimate, but **never sexually explicit**. This must be enforced at the system-prompt level AND via an output moderation pass — never rely on the model's default behavior alone.

**USP:** "A companion that remembers you — not just facts, but the shape of your relationship — in an app that feels premium, not sleazy."

**Target user (primary persona for MVP):** Companionship-seekers wanting a consistent, emotionally present AI relationship (not casual roleplay browsers — that's a later phase).

**Tone/brand feel:** Modern, warm, premium, mobile-first. Avoid neon/anime aesthetic common in competitors — lean toward soft, human, editorial design (think Headspace/Calm warmth crossed with a premium subscription product like Superhuman).

---

## 2. MVP Scope (build this first — nothing more)

**In scope for MVP:**
- Email + Google OAuth authentication
- Browse a curated roster of pre-made companions (3–5 to start, admin-seeded, not user-created)
- Companion profile page (bio, personality preview, "Start Chat" CTA)
- 1:1 real-time streaming chat with a companion
- Persistent conversation history per user-companion pair
- Long-term memory: background extraction of durable facts from conversations, recalled in future sessions via vector similarity search
- Personality consistency via structured system prompts per companion
- Free tier (daily message cap) + paid subscription tier (Stripe) with higher/unlimited cap
- Account settings: profile, subscription management, delete account (GDPR-style data deletion)
- Output moderation layer enforcing the non-explicit content boundary regardless of user prompting

**Explicitly OUT of scope for MVP (do not build yet):**
- User-created/customizable companions
- Favorites / multiple simultaneous companion relationships
- Voice messages, generated images, voice calls
- Push notifications / companion-initiated messages
- Credits system (subscription only for MVP; credits layer comes in Phase 2.5)
- Referrals/social features

If asked to build something outside MVP scope, flag it and confirm before proceeding.

---

## 3. Core User Journey

```
Landing page → Sign up → (optional) short preference quiz
→ Browse companions → Select companion → First conversation
  (companion sends the first message — never a blank chat box)
→ Ongoing conversation, memory builds silently in background
→ Hit free tier limit → Soft paywall → Subscribe
→ Return visits: companion references past conversation naturally
```

Design/build priority: the chat interface and first-conversation experience matter more than any other screen. Polish this before anything else.

---

## 4. Technology Stack (fixed — do not substitute without discussion)

| Layer | Choice |
|---|---|
| Frontend | Next.js (App Router) + TypeScript |
| Styling | Tailwind CSS + shadcn/ui |
| Backend | Fastify (Node.js) + TypeScript, separate service from frontend |
| Database | PostgreSQL with pgvector extension |
| ORM | Prisma |
| Cache/Queue | Redis + BullMQ (background jobs: memory extraction, moderation) |
| Auth | Auth.js (NextAuth) |
| LLM Provider | Anthropic Claude API — abstracted behind an interface so providers/models can be swapped later |
| File storage | Cloudflare R2 (S3-compatible) — not needed until Phase 4 (media) |
| Payments | Stripe |
| Realtime chat delivery | Server-Sent Events (SSE) for token streaming — not WebSockets |
| Hosting | Frontend: Vercel. Backend: Railway or Fly.io. DB: Neon (managed Postgres). Redis: Upstash. |
| Package management | pnpm workspaces (monorepo) |

**Architectural principles to follow throughout:**
- Memory extraction runs **asynchronously** in a background worker after each conversation turn/batch — never inline with the chat response (keeps latency low).
- A moderation check sits between LLM output and the user-facing response to enforce the content boundary — treat this as non-negotiable infrastructure, not an afterthought.
- The LLM client is abstracted (single module/interface) so a second model tier (cheap vs. premium) can be added later without touching chat logic elsewhere.
- Keep the backend framework-light (Fastify has no built-in DI) but enforce folder discipline manually — see file structure below.

---

## 5. Repo / File Structure

See the repository. Packages live under `apps/web`, `apps/api`, and `packages/db`.

---

## 6. Database Schema

See `packages/db/prisma/schema.prisma`.

---

## 7. Page/Screen Structure

```
/                        - Marketing landing page (SSR, SEO)
/login, /signup          - Auth
/onboarding              - Optional short preference quiz
/discover                - Browse companions (grid, tag filters)
/companion/[slug]        - Companion profile + "Start Chat"
/chat/[relationshipId]   - Main chat interface (highest design priority)
/conversations           - List of active companion relationships
/settings                - Account, privacy, delete account
/settings/billing        - Stripe billing portal
/pricing                 - Plan comparison, upgrade CTA
```

---

## 8. Build Phases (follow in order — do not skip ahead)

**Phase 0 — Scaffolding** (this commit / this session)
Set up monorepo, Next.js app, Fastify app, Prisma schema + migration, deploy skeletons. Confirm build/deploy pipeline works before writing feature code.

**Phase 1 — Core Loop**
Auth → seed 3 companions → companion browse/profile pages → chat UI with SSE streaming → conversation persistence → memory extraction worker (basic) → moderation worker (basic keyword/classifier pass enforcing non-explicit boundary).

**Phase 2 — Monetization**
Free tier message limits, Stripe subscription checkout, webhook handling, billing portal, paywall UI.

**Phase 3 — Personalization**
User-created/customizable companions, favorites, richer profile options.

**Phase 4 — Media**
TTS voice messages, generated companion images (static pool first, dynamic later).

**Phase 5 — Growth**
Notifications, companion-initiated messages, referrals.

Work through exactly one phase at a time. Do not generate Phase 2+ code while working on Phase 0/1.

---

## 9. Non-negotiable Constraints

- Content boundary (romantic, non-explicit) must be enforced server-side, not just via prompt instruction.
- All user data deletion requests must cascade properly (conversations, messages, memories tied to a user must be deletable).
- No secrets/API keys committed to the repo — use environment variables throughout.
- Keep the LLM provider call behind a single abstraction (`apps/api/src/lib/claude-client.ts`) from day one.
