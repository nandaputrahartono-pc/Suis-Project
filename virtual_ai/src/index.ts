import 'dotenv/config';
import Fastify from 'fastify';
import cors from '@fastify/cors';
import { chatRoutes } from './routes/chat.js';

/**
 * Suis AI Backend — Entry Point
 * 
 * Fastify server yang berfungsi sebagai proxy aman ke Groq API.
 * API key Groq tersimpan aman di server, Flutter tidak perlu tau.
 */

const PORT = parseInt(process.env.PORT || '3000', 10);

// Inisialisasi Fastify dengan logger
const fastify = Fastify({
  logger: {
    level: 'info',
    transport: {
      target: 'pino-pretty',
      options: {
        translateTime: 'HH:MM:ss Z',
        ignore: 'pid,hostname',
        colorize: true,
      },
    },
  },
});

async function main() {
  // Register CORS — izinkan semua origin (untuk development)
  // Nanti di production, batasi ke domain/IP tertentu
  await fastify.register(cors, {
    origin: true,
    methods: ['GET', 'POST'],
  });

  // Register routes
  await fastify.register(chatRoutes);

  // Root route
  fastify.get('/', async () => {
    return {
      name: 'Suis AI Backend',
      version: '1.0.0',
      docs: '/api/health',
    };
  });

  // Start server
  try {
    await fastify.listen({ port: PORT, host: '0.0.0.0' });
    console.log(`\n🚀 Suis AI Backend berjalan di http://localhost:${PORT}`);
    console.log(`📋 Health check: http://localhost:${PORT}/api/health`);
    console.log(`💬 Chat endpoint: POST http://localhost:${PORT}/api/chat\n`);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
}

// Graceful shutdown
const signals: NodeJS.Signals[] = ['SIGINT', 'SIGTERM'];
signals.forEach((signal) => {
  process.on(signal, async () => {
    console.log(`\n⏹️  ${signal} received. Shutting down gracefully...`);
    await fastify.close();
    process.exit(0);
  });
});

main();
