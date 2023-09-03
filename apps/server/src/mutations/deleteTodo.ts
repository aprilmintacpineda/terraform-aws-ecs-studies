import { TRPCError } from '@trpc/server';
import * as yup from 'yup';
import TodosModel from '../models/todos';
import type { TodoJSON } from '../models/todos/schema';
import { trpc } from '../trpc';

const deleteTodo = trpc.procedure
  .input(
    yup.object({
      id: yup.string().required()
    })
  )
  .mutation<TodoJSON>(async ({ input }) => {
    const todo = await TodosModel.findByIdAndDelete(input.id, {
      completedAt: new Date()
    });

    if (!todo) throw new TRPCError({ code: 'NOT_FOUND' });

    return todo.toJSON();
  });

export default deleteTodo;
