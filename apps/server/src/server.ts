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
      mongoose.connect(env.MONGODB_URI, {
        user: env.MONGODB_USER,
        pass: env.MONGODB_PASS,
        dbName: env.MONGODB_DBNAME
      }),
      server.register(cors, {}),
      server.register(fastifyTRPCPlugin, {
        prefix: '/trpc',
        trpcOptions: { router: appRouter, createContext }
      })
    ]);

    // just a health check endpoint necessary for ECS
    server.get('/health', async (request, reply) => {
      try {
        const result = await mongoose.connection.db.admin().ping();

        console.log('health', result);

        if (result.ok) reply.status(200).send();
        else reply.status(500).send();
      } catch (error) {
        console.log('health', error);
        reply.status(500).send();
      }
    });

    // load test
    server.get('/load-test', async (request, reply) => {
      function permutations (
        arr: (string | number)[]
      ): (string | number)[][] {
        const result: (string | number)[][] = [];

        function permute (
          current: (string | number)[],
          remaining: (string | number)[]
        ) {
          if (remaining.length === 0) {
            result.push([...current]);
            return;
          }

          for (let i = 0; i < remaining.length; i++) {
            const nextValue = remaining[i];
            current.push(nextValue);
            const nextRemaining = [
              ...remaining.slice(0, i),
              ...remaining.slice(i + 1)
            ];
            permute(current, nextRemaining);
            current.pop();
          }
        }

        permute([], arr);

        return result;
      }

      reply
        .status(200)
        .send(
          permutations(
            Math.random().toString(32).substring(5).split('')
          )
        );
    });

    await server.listen({ port: 3000, host: '0.0.0.0' });

    console.log('http://localhost:3000');
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
