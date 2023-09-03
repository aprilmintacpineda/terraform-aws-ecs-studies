import type { inferAsyncReturnType } from '@trpc/server';
import type { CreateFastifyContextOptions } from '@trpc/server/adapters/fastify';

export function createContext ({
  req,
  res
}: CreateFastifyContextOptions) {
  console.log({ req, res });
}

export type Context = inferAsyncReturnType<typeof createContext>;
