import type { inferAsyncReturnType } from '@trpc/server';
import type { CreateFastifyContextOptions } from '@trpc/server/adapters/fastify';

export function createContext ({
  req: _1,
  res: _2
}: CreateFastifyContextOptions) {}

export type Context = inferAsyncReturnType<typeof createContext>;
