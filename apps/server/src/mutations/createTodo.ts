import * as yup from 'yup';
import TodosModel from '../models/todos';
import type { TodoJSON } from '../models/todos/schema';
import { trpc } from '../trpc';

const createTodo = trpc.procedure
  .input(
    yup.object({
      title: yup.string().required().max(255)
    })
  )
  .mutation<TodoJSON>(async ({ input }) => {
    const todo = await TodosModel.create(input);
    return todo.toJSON();
  });

export default createTodo;
