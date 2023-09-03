require('dotenv').config();

import * as yup from 'yup';

const validationSchema = yup.object({
  MONGO_DB: yup.string().required()
});

const env = validationSchema.validateSync(process.env);

export default env;
