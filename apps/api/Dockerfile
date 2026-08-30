# syntax=docker/dockerfile:1
# Build from repository root:
#   docker build -f apps/api/Dockerfile .

FROM node:24-alpine AS base
RUN corepack enable && corepack prepare pnpm@9.15.9 --activate
WORKDIR /app

FROM base AS build
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml turbo.json .npmrc tsconfig.base.json ./
COPY apps/api/package.json apps/api/package.json
COPY packages/db/package.json packages/db/package.json
RUN pnpm install --frozen-lockfile
COPY apps/api apps/api
COPY packages/db packages/db
RUN pnpm --filter @nyra/db generate && pnpm --filter @nyra/api build

FROM node:24-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV API_PORT=3001
ENV API_HOST=0.0.0.0
COPY --from=build /app /app
WORKDIR /app/apps/api
EXPOSE 3001
CMD ["pnpm", "start"]
