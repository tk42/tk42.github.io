import { defineCollection, z } from "astro:content";

// Tags can be a comma-separated string or an array of strings
const tagsSchema = z
  .union([z.string(), z.array(z.string())])
  .nullable()
  .optional()
  .transform((val) => {
    if (!val) return [];
    if (Array.isArray(val)) return val.map(String);
    return val.split(",").map((t: string) => t.trim());
  });

const commonSchema = z.object({
  title: z.string(),
  date: z.coerce.string().optional(),
  tags: tagsSchema,
  feed: z.enum(["show", "hide"]).optional(),
  publish: z.boolean().optional().default(true),
  "content-type": z.string().optional(),
  format: z.string().optional(),
});

const notes = defineCollection({
  type: "content",
  schema: commonSchema,
});

const memos = defineCollection({
  type: "content",
  schema: commonSchema,
});

export const collections = { notes, memos };
