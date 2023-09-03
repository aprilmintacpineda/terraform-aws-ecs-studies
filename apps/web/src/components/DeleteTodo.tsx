import { IconButton } from '@mui/material';
import React, { useCallback } from 'react';
import { Serialize } from '@trpc/server/shared';
import { TodoJSON } from '@terraform-aws-ecs/server/src/models/todos/schema';
import { trpc } from '../utils/trpc';
import { enqueueSnackbar } from 'notistack';
import DeleteForeverIcon from '@mui/icons-material/DeleteForever';

type Props = {
  todo: Serialize<TodoJSON>;
};

const DeleteTodo: React.FunctionComponent<Props> = ({ todo }) => {
  const { mutate, isLoading, isSuccess } =
    trpc.deleteTodo.useMutation();
  const trpcContext = trpc.useContext();
  const invalidateListTodo = trpcContext.listTodos.invalidate;

  const deleteTodo = useCallback(() => {
    mutate(
      { id: todo._id },
      {
        onError: () => {
          enqueueSnackbar(
            'Failed to mark todo as completed. An unknown error occured.',
            { variant: 'error' }
          );
        },
        onSuccess: () => {
          invalidateListTodo();
        }
      }
    );
  }, [invalidateListTodo, mutate, todo]);

  return (
    <IconButton
      size="small"
      disabled={isLoading || isSuccess}
      onClick={deleteTodo}
      color="error"
    >
      <DeleteForeverIcon />
    </IconButton>
  );
};

export default DeleteTodo;
