import * as yup from 'yup';

const validationSchema = yup.object({
  VITE_TRPC_ENDPOINT: yup.string().required()
});

const env = validationSchema.validateSync(import.meta.env, {
  abortEarly: false,
  stripUnknown: true
});

export default env;
