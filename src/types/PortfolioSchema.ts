import { z } from 'zod';

const LanguageSchema = z.object({
    language: z.string(),
    level: z.string(),
});

const ExperienceSchema = z.object({
    title: z.string(),
    role: z.string(),
    place: z.string(),
    interval: z.string(),
    responsabilities: z.array(z.string()),
    tecnologies: z.array(z.string()),
    diploma: z.string().optional(),
    alt: z.string().optional(),

});

const ProjectSchema = z.object({
    name: z.string(),
    description: z.string(),
    link: z.string(),
});

const MetadataSchema = z.object({
    language: z.string(),
    webTitle: z.string(),
    title: z.string(),
    description: z.string(),
})

export const PortfolioSchema = z.object({
    role: z.string(),
    introduction: z.string(),
    languages: z.array(LanguageSchema),
    jobs: z.array(ExperienceSchema),
    education: z.array(ExperienceSchema),
    projects: z.array(ProjectSchema),
    metadata: MetadataSchema,
});

export type LanguageType = z.infer<typeof LanguageSchema>;
export type PortfolioType = z.infer<typeof PortfolioSchema>;
export type ExperienceType = z.infer<typeof ExperienceSchema>;
export type ProjectType = z.infer<typeof ProjectSchema>;