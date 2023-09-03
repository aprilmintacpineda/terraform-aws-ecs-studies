import { IconButton } from '@mui/material';
import React, { useCallback } from 'react';
import CheckIcon from '@mui/icons-material/Check';
import { Serialize } from '@trpc/server/shared';
import { TodoJSON } from '@terraform-aws-ecs/server/src/models/todos/schema';
import { trpc } from '../utils/trpc';
import { enqueueSnackbar } from 'notistack';

type Props = {
  todo: Serialize<TodoJSON>;
};

const CompleteTodo: React.FunctionComponent<Props> = ({ todo }) => {
  const { mutate, isLoading, isSuccess } =
    trpc.completeTodo.useMutation();
  const trpcContext = trpc.useContext();
  const invalidateListTodo = trpcContext.listTodos.invalidate;

  const markAsComplete = useCallback(() => {
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
      onClick={markAsComplete}
      color="primary"
    >
      <CheckIcon />
    </IconButton>
  );
};

export default CompleteTodo;
