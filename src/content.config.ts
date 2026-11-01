import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
import { docsLoader } from '@astrojs/starlight/loaders';
import { docsSchema } from '@astrojs/starlight/schema';

export const collections = {
	docs: defineCollection({
		loader: docsLoader(),
		schema: docsSchema({
			// Used by the home page's hero (src/components/Hero.astro).
			extend: z.object({
				heroNote: z.string().optional(),
				heroCaption: z.string().optional(),
				// News posts (src/content/docs/news/): the day it was posted, shown under the
				// title and used to order the news page (src/components/NewsList.astro).
				date: z.coerce.date().optional(),
			}),
		}),
	}),
};
