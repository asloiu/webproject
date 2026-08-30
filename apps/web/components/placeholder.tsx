export function Placeholder({
  title,
  note,
}: {
  title: string;
  note?: string;
}) {
  return (
    <main className="mx-auto flex min-h-screen max-w-lg flex-col justify-center px-6 py-16">
      <p className="text-sm tracking-[0.2em] text-[var(--muted)] uppercase">Nyra</p>
      <h1
        className="mt-3 text-4xl font-light tracking-tight"
        style={{ fontFamily: "var(--font-serif), ui-serif, Georgia, serif" }}
      >
        {title}
      </h1>
      <p className="mt-4 text-[var(--muted)] leading-relaxed">
        {note ?? "Phase 0 scaffold. Screens ship in Phase 1."}
      </p>
    </main>
  );
}
