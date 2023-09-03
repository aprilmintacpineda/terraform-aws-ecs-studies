import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from '@terraform-aws-ecs/server/src/router';

export const trpc = createTRPCReact<AppRouter>();
