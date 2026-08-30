import { Placeholder } from "@/components/placeholder";

export default async function ChatPage({
  params,
}: {
  params: Promise<{ relationshipId: string }>;
}) {
  const { relationshipId } = await params;
  return (
    <Placeholder
      title="Chat"
      note={`Relationship ${relationshipId}. Chat UI is the Phase 1 design priority.`}
    />
  );
}
