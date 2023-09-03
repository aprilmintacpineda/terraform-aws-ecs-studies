import { Box, TextField } from '@mui/material';
import { Form, Formik, FormikHelpers } from 'formik';
import React, { useCallback, useEffect, useRef } from 'react';
import { trpc } from '../utils/trpc';
import * as yup from 'yup';
import { enqueueSnackbar } from 'notistack';

const initialValues = {
  title: ''
};

type Form = typeof initialValues;

const validationSchema = yup.object({
  title: yup
    .string()
    .required('Please enter title.')
    .max(255, 'Please enter something less than 255 characters.')
});

const AddTodoForm: React.FunctionComponent = () => {
  const { mutate: createTodo } = trpc.createTodo.useMutation();
  const trpcContext = trpc.useContext();
  const invalidateListTodos = trpcContext.listTodos.invalidate;
  const textFieldRef = useRef<HTMLInputElement>(null);
  const focusTimerRef = useRef<NodeJS.Timeout>();

  const submit = useCallback(
    (form: Form, { resetForm }: FormikHelpers<Form>) => {
      createTodo(form, {
        onError: () => {
          enqueueSnackbar(
            'Failed to add todo. An unknown error occured.',
            {
              variant: 'error'
            }
          );
        },
        onSuccess: () => {
          invalidateListTodos();

          resetForm({
            values: initialValues
          });

          focusTimerRef.current = setTimeout(() => {
            textFieldRef.current?.focus();
          }, 50);
        }
      });
    },
    [invalidateListTodos, createTodo]
  );

  useEffect(() => {
    return () => {
      if (focusTimerRef.current) clearTimeout(focusTimerRef.current);
    };
  }, []);

  return (
    <Box>
      <Formik
        onSubmit={submit}
        initialValues={initialValues}
        validationSchema={validationSchema}
      >
        {({ handleChange, errors, isSubmitting, values }) => {
          return (
            <Form>
              <TextField
                value={values.title}
                size="small"
                placeholder="e.g., Buy eggs"
                onChange={handleChange('title')}
                error={Boolean(errors.title)}
                helperText={errors.title}
                disabled={isSubmitting}
                fullWidth
                inputRef={textFieldRef}
              />
            </Form>
          );
        }}
      </Formik>
    </Box>
  );
};

export default AddTodoForm;
