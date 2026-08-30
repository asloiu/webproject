# Nyra (placeholder)

AI companion platform. Brand name is not final.

**Current phase:** 0 — scaffolding only. Feature work starts in Phase 1.

## Requirements

- Node.js 20+ (LTS)
- pnpm 9 (`corepack enable` then `corepack prepare pnpm@9.15.9 --activate`)
- PostgreSQL with `pgvector` (Neon for hosted)
- Redis (Upstash for hosted) — not required to boot the API skeleton

## Setup

```bash
cp .env.example .env
cp apps/web/.env.example apps/web/.env.local
cp apps/api/.env.example apps/api/.env
pnpm install
pnpm db:generate
# requires DATABASE_URL
pnpm db:migrate
pnpm dev
```

- Web: http://localhost:3000
- API health: http://localhost:3001/health

## Deploy (skeletons)

| App | Host | Notes |
|---|---|---|
| `apps/web` | Vercel | Set root directory to `apps/web` (or use Turborepo preset). |
| `apps/api` | Railway or Fly.io | Dockerfile at `apps/api/Dockerfile`. Health check: `GET /health`. |
| Database | Neon | Enable pgvector. |
| Redis | Upstash | Used from Phase 1 workers. |

Do not commit secrets. Copy `.env.example` files locally.

## Spec

See [docs/MASTER_SPEC.md](docs/MASTER_SPEC.md).
