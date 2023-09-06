import cors from '@fastify/cors';
import { fastifyTRPCPlugin } from '@trpc/server/adapters/fastify';
import fastify from 'fastify';
import mongoose from 'mongoose';
import { createContext } from './context';
import env from './env';
import { appRouter } from './router';

const server = fastify({
  maxParamLength: 5000
});

(async () => {
  try {
    await Promise.all([
      mongoose.connect(env.MONGO_DB),
      server.register(cors, {}),
      server.register(fastifyTRPCPlugin, {
        prefix: '/trpc',
        trpcOptions: { router: appRouter, createContext }
      })
    ]);

    // just a health check endpoint necessary for ECS
    server.get('/health', (request, reply) => {
      reply.status(200).send('Healthy');
    });

    await server.listen({ port: 3000, host: '0.0.0.0' });

    console.log('http://localhost:3000');
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
})();
