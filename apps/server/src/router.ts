import completeTodo from './mutations/completeTodo';
import createTodo from './mutations/createTodo';
import deleteTodo from './mutations/deleteTodo';
import listTodos from './queries/listTodos';
import { trpc } from './trpc';

export const appRouter = trpc.router({
  createTodo,
  listTodos,
  completeTodo,
  deleteTodo
});

export type AppRouter = typeof appRouter;
