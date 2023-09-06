import {
  QueryClient,
  QueryClientProvider
} from '@tanstack/react-query';
import { httpBatchLink } from '@trpc/client';
import { trpc } from './utils/trpc';
import { ThemeProvider, createTheme } from '@mui/material';
import Todos from './components/Todos';
import { SnackbarProvider } from 'notistack';
import env from './env';

const theme = createTheme({
  components: {
    MuiLink: {
      styleOverrides: {
        root: {
          cursor: 'pointer'
        }
      }
    }
  }
});

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
      refetchOnWindowFocus: false
    }
  }
});

const trpcClient = trpc.createClient({
  links: [
    httpBatchLink({
      url: env.VITE_TRPC_ENDPOINT,

      // You can pass any HTTP headers you wish here
      async headers() {
        return {};
      }
    })
  ]
});

const App: React.FunctionComponent = () => {
  return (
    <trpc.Provider client={trpcClient} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider theme={theme}>
          <Todos />
          <SnackbarProvider />
        </ThemeProvider>
      </QueryClientProvider>
    </trpc.Provider>
  );
};

export default App;
