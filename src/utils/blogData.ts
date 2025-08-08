import rss from '@astrojs/rss';
import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';
import sanitizeHtml from 'sanitize-html';
import MarkdownIt from 'markdown-it';
const parser = new MarkdownIt();

export async function getPosts(language: string) {
    return await getCollection("blog", ({ data, id }) => {
        return data.publish && id.startsWith(`${language}/`);
    });
}

export function getRssFeed(language: string): APIRoute {
    return async () => {
        const posts = await getPosts(language);
        const year = new Date().getFullYear();
        const copyright = language === "es" ? `© ${year} Jorge Calderita. Todos los derechos reservados.` : `© ${year} Jorge Calderita. All rights reserved.`;
        const title = language === "es" ? "Blog de Jorge Calderita" : "Jorge Calderita's Blog";
        const description = language === "es" ? "Blog personal de Jorge Calderita" : "Jorge Calderita's personal Blog";
        const customData = `<language>${language === 'es' ? 'es-es' : 'en-us'}</language> <copyright>${copyright}</copyright>`
        return rss({
            title,
            description,
            site: `https://jcalderita.com/${language}`,
            xmlns: {
                media: 'http://search.yahoo.com/mrss/',
            },
            items: posts.map(({ data, slug, body }) => ({
                pubDate: data.date,
                link: `/${language}/blog/${slug}`,
                content: sanitizeHtml(parser.render(body), {
                    allowedTags: sanitizeHtml.defaults.allowedTags.concat(['img'])
                }),
                ...data,
                customData: `<media:content type="image/webp" width="${data.cover.width}" height="${data.cover.height}" medium="image" url="${`https://jcalderita.com/blog/` + data.publicCover}" /> <media:description>${data.coverDescription}</media:description>`,
            })),
            customData,
        });
    };
}