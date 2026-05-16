import { FastifyInstance } from 'fastify';
import { generateChatResponse, ChatRequest } from '../services/groq.service.js';
import { generateSpeech } from '../services/tts.service.js';

/**
 * Register semua route terkait chat AI.
 */
export async function chatRoutes(fastify: FastifyInstance) {

  /**
   * GET /api/health — Health check endpoint
   */
  fastify.get('/api/health', async (_request, _reply) => {
    return {
      status: 'ok',
      service: 'Suis AI Backend',
      timestamp: new Date().toISOString(),
    };
  });

  /**
   * POST /api/chat — Endpoint utama untuk chat AI
   * 
   * Body: {
   *   "messages": [
   *     { "role": "user", "content": "Halo!" }
   *   ],
   *   "model": "Queen"  // opsional, default: Queen
   * }
   */
  fastify.post<{ Body: ChatRequest }>('/api/chat', async (request, reply) => {
    const { messages, model } = request.body;

    // Validasi input
    if (!messages || !Array.isArray(messages) || messages.length === 0) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Field "messages" harus berupa array dan tidak boleh kosong.',
      });
    }

    // Validasi setiap message punya role dan content
    for (const msg of messages) {
      if (!msg.role || !msg.content) {
        return reply.status(400).send({
          error: 'Bad Request',
          message: 'Setiap message harus punya "role" dan "content".',
        });
      }
    }

    try {
      const result = await generateChatResponse(messages, model);
      return reply.send(result);
    } catch (error: unknown) {
      const err = error as { status?: number; message?: string };
      
      // Handle rate limit dari Groq
      if (err.status === 429) {
        fastify.log.warn('Groq rate limit reached');
        return reply.status(429).send({
          error: 'Rate Limit',
          message: 'Wah, Suis AI lagi capek nih. Coba lagi beberapa detik ya!',
        });
      }

      // Handle authentication error
      if (err.status === 401) {
        fastify.log.error('Groq API key invalid');
        return reply.status(500).send({
          error: 'Server Error',
          message: 'Ada masalah konfigurasi server. Hubungi admin.',
        });
      }

      // General error
      fastify.log.error(err, 'Error generating chat response');
      return reply.status(500).send({
        error: 'Server Error',
        message: 'Maaf, ada kesalahan di server. Coba lagi nanti ya.',
      });
    }
  });

  /**
   * POST /api/tts — Text-to-Speech endpoint
   * 
   * Body: { "text": "Halo, aku Suis AI" }
   * Response: Audio MP3 binary
   * Header X-Word-Boundaries: JSON array of word timing data
   */
  fastify.post<{ Body: { text: string } }>('/api/tts', async (request, reply) => {
    const { text } = request.body;

    if (!text || typeof text !== 'string' || text.trim().length === 0) {
      return reply.status(400).send({
        error: 'Bad Request',
        message: 'Field "text" harus berupa string dan tidak boleh kosong.',
      });
    }

    try {
      const result = await generateSpeech(text.trim());
      
      return reply
        .header('Content-Type', 'audio/mpeg')
        .header('Content-Length', result.audio.length)
        .header('X-Word-Boundaries', JSON.stringify(result.wordBoundaries))
        .header('Access-Control-Expose-Headers', 'X-Word-Boundaries')
        .send(result.audio);
    } catch (error: unknown) {
      fastify.log.error(error, 'Error generating TTS');
      return reply.status(500).send({
        error: 'TTS Error',
        message: 'Gagal menghasilkan suara. Coba lagi.',
      });
    }
  });
}
