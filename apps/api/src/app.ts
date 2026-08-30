import Fastify from "fastify";

export function buildApp() {
  const app = Fastify({
    logger: true,
  });

  app.get("/health", async () => ({
    ok: true,
    service: "nyra-api",
    phase: 0,
  }));

  return app;
}
