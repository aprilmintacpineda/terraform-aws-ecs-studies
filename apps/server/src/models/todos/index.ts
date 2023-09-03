import mongoose from 'mongoose';
import { todosSchema } from './schema';

const TodosModel = mongoose.model('Todo', todosSchema);

export default TodosModel;
