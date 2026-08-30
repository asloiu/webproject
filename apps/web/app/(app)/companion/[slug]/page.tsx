import { Placeholder } from "@/components/placeholder";

export default async function CompanionPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  return <Placeholder title={slug} note="Companion profile lands in Phase 1." />;
}
