import { Card, CardContent, Stack, Typography } from '@mui/material';
import { TodoJSON } from '@terraform-aws-ecs/server/src/models/todos/schema';
import { Serialize } from '@trpc/server/shared';
import React from 'react';
import TimeAgo from './TimeAgo';
import CompleteTodo from './CompleteTodo';
import DeleteTodo from './DeleteTodo';

type Props = {
  todo: Serialize<TodoJSON>;
};

const Todo: React.FunctionComponent<Props> = ({ todo }) => {
  return (
    <Card sx={{ width: '100%', marginBottom: 1 }} data-testid="todo">
      <CardContent>
        <Stack
          flexDirection="row"
          justifyContent="space-between"
          alignItems="center"
        >
          <Typography variant="h5">{todo.title}</Typography>
          {todo.completedAt ? (
            <DeleteTodo todo={todo} />
          ) : (
            <CompleteTodo todo={todo} />
          )}
        </Stack>
        {todo.completedAt && (
          <Typography variant="caption">
            <TimeAgo startDate={todo.completedAt} />
          </Typography>
        )}
      </CardContent>
    </Card>
  );
};

export default Todo;
