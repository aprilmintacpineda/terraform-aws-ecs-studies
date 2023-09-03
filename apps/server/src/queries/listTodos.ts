import TodosModel from '../models/todos';
import type { TodoJSON } from '../models/todos/schema';
import { trpc } from '../trpc';

const listTodos = trpc.procedure.query<TodoJSON[]>(async () => {
  const todos = await TodosModel.find().sort({
    createdAt: -1
  });

  return todos.map(todo => todo.toJSON());
});

export default listTodos;
