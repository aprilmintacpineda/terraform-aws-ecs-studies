import { Stack, Typography } from '@mui/material';
import { TodoJSON } from '@terraform-aws-ecs/server/src/models/todos/schema';
import { Serialize } from '@trpc/server/shared';
import Todo from './Todo';

type Props = {
  todos: Serialize<TodoJSON[]>;
};

const TodoList: React.FunctionComponent<Props> = ({ todos }) => {
  if (!todos.length) {
    return (
      <Typography textAlign="center">
        You have no todos yet.
      </Typography>
    );
  }

  return (
    <Stack justifyContent="center" alignItems="center">
      {todos.map(todo => (
        <Todo key={todo._id} todo={todo} />
      ))}
    </Stack>
  );
};

export default TodoList;
