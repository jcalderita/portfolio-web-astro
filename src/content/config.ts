import { defineCollection, z } from "astro:content";

const blogCollection = defineCollection({
    type: 'content',
    schema: ({ image }) => z.object({
        title: z.string(),
        date: z.date(),
        author: z.string(),
        description: z.string(),
        tags: z.array(z.string()),
        cover: image(),
        publicCover: z.string(),
        coverDescription: z.string(),
        publish: z.boolean()
    }),
});

export const collections = {
    'blog': blogCollection,
};