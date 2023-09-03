import type { Document, InferSchemaType } from 'mongoose';
import mongoose from 'mongoose';

export const todosSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    completedAt: { type: Date }
  },
  {
    timestamps: true
  }
);

export type TodoSchema = InferSchemaType<typeof todosSchema>;

export type TodoDocument = Document<unknown, object, TodoSchema> &
  Omit<
    TodoSchema &
      Required<{
        _id: string;
      }>,
    never
  >;

export type TodoJSON = ReturnType<typeof convertToJson>;

export function convertToJson (doc: TodoDocument) {
  return doc.toJSON();
}
