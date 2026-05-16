import Groq from 'groq-sdk';
import { SUIS_SYSTEM_PROMPT, MODEL_MAP, DEFAULT_MODEL } from '../config/prompts.js';

/**
 * Interface untuk pesan chat yang dikirim dari Flutter.
 */
export interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

/**
 * Interface untuk request body dari Flutter.
 */
export interface ChatRequest {
  messages: ChatMessage[];
  model?: string; // Nama model: 'Queen', 'GPT', 'Claude'
}

/**
 * Interface untuk response ke Flutter.
 */
export interface ChatResponse {
  response: string;
  model: string;
}

// Inisialisasi Groq client
const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

/**
 * Resolve nama model dari Flutter ke Groq model ID.
 * Contoh: 'Queen' → 'llama-3.3-70b-versatile'
 */
function resolveModel(modelName?: string): string {
  if (!modelName) return DEFAULT_MODEL;
  return MODEL_MAP[modelName] || DEFAULT_MODEL;
}

/**
 * Generate respons chat dari Groq API.
 * 
 * @param messages - Array pesan chat history dari Flutter
 * @param modelName - Nama model yang dipilih user (Queen/GPT/Claude)
 * @returns ChatResponse dengan teks balasan AI dan model yang digunakan
 */
export async function generateChatResponse(
  messages: ChatMessage[],
  modelName?: string
): Promise<ChatResponse> {
  const groqModel = resolveModel(modelName);

  // Siapkan messages dengan system prompt di depan
  const fullMessages: ChatMessage[] = [
    { role: 'system', content: SUIS_SYSTEM_PROMPT },
    ...messages,
  ];

  const completion = await groq.chat.completions.create({
    messages: fullMessages,
    model: groqModel,
    temperature: 0.7,
    max_tokens: 1024,
    top_p: 0.9,
  });

  const responseText = completion.choices[0]?.message?.content || 'Maaf, aku nggak bisa merespon saat ini.';

  return {
    response: responseText,
    model: groqModel,
  };
}
