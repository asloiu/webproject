/**
 * Redis client. Connection is deferred until Phase 1 workers (BullMQ).
 * Do not connect at process boot in Phase 0.
 */
export function getRedisUrl(): string {
  const url = process.env.REDIS_URL;
  if (!url) {
    throw new Error("REDIS_URL is not set");
  }
  return url;
}
