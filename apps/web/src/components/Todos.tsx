import {
  CircularProgress,
  Container,
  Link,
  Stack,
  Typography
} from '@mui/material';
import { trpc } from '../utils/trpc';
import TodoList from './TodoList';
import AddTodoForm from './AddTodoForm';

const Todos: React.FunctionComponent = () => {
  const todos = trpc.listTodos.useQuery();

  return (
    <Container
      sx={{
        marginTop: 10,
        marginBottom: 10,
        maxWidth: '800px !important'
      }}
    >
      <Stack
        justifyContent="center"
        alignItems="center"
        marginBottom={1}
      >
        <Typography variant="h4">Todo List</Typography>
        <Typography variant="caption" textAlign="center">
          This todo list was created with React+ViteJS, NodeJS,
          MongoDB+Mongoose, TRPC. Dockerized and deployed to AWS ECS
          Fargate using Terraform.
        </Typography>
      </Stack>
      <Stack marginBottom={1}>
        <AddTodoForm />
      </Stack>
      {todos.status === 'success' ? (
        <TodoList todos={todos.data} />
      ) : todos.status === 'error' ? (
        <Typography textAlign="center">
          An unknown error occured. Please{' '}
          <Link onClick={() => todos.refetch()}>try again</Link>.
        </Typography>
      ) : (
        <Stack justifyContent="center" alignItems="center">
          <CircularProgress />
        </Stack>
      )}
    </Container>
  );
};

export default Todos;
