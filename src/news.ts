// News posts are pages in src/content/docs/news/ with a `date` in their frontmatter.
import { getCollection, type CollectionEntry } from 'astro:content';

export type NewsPost = CollectionEntry<'docs'> & { data: { date: Date } };

/** Every published news post, newest first. Drafts show in dev only. */
export async function newsPosts(): Promise<NewsPost[]> {
	const posts = await getCollection(
		'docs',
		(entry): entry is NewsPost =>
			entry.id.startsWith('news/') && !!entry.data.date && (import.meta.env.DEV || !entry.data.draft),
	);
	return posts.sort((a, b) => b.data.date.getTime() - a.data.date.getTime());
}

/** "1 November 2026". Dates are days, so they're read and shown in UTC. */
export function formatDate(date: Date): string {
	return date.toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' });
}
