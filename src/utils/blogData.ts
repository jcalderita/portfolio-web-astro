import { getCollection } from 'astro:content';


export async function getPosts(language: string) {
    return await getCollection("blog", ({ data, id }) => {
        return data.publish && id.startsWith(`${language}/`);
    });
}