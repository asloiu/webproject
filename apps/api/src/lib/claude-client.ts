/**
 * Single LLM provider abstraction. All chat/completion calls go through this module.
 * Streaming and Anthropic wiring land in Phase 1 — do not call providers from routes directly.
 */

export type LlmRole = "user" | "assistant" | "system";

export type LlmMessage = {
  role: LlmRole;
  content: string;
};

export type LlmStreamParams = {
  messages: LlmMessage[];
  system?: string;
};

export interface LlmClient {
  streamChat(params: LlmStreamParams): AsyncIterable<string>;
}

export class AnthropicLlmClient implements LlmClient {
  async *streamChat(_params: LlmStreamParams): AsyncIterable<string> {
    throw new Error("LLM streaming is implemented in Phase 1");
  }
}

export function createLlmClient(): LlmClient {
  return new AnthropicLlmClient();
}
