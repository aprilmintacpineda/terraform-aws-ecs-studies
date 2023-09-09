require('dotenv').config();

import * as yup from 'yup';

const validationSchema = yup.object({
  MONGODB_URI: yup.string().required(),
  MONGODB_PASS: yup.string(),
  MONGODB_USER: yup.string(),
  MONGODB_DBNAME: yup.string().required()
});

const env = validationSchema.validateSync(process.env);

export default env;
