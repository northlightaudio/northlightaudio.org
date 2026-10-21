// Adjusts each page's <head> before Starlight renders it: the share image for every
// page, and a proper title for the home page, which would otherwise be shared as "Home".
import { defineRouteMiddleware } from '@astrojs/starlight/route-data';

const image = {
	path: '/og-image.jpg',
	width: '1200',
	height: '630',
	alt: 'Northlight: Music belongs to everyone. A free and open source studio for recording, arranging and mixing music on Windows.',
};

const homeTitle = 'Northlight | Music belongs to everyone';

export const onRequest = defineRouteMiddleware((context) => {
	const route = context.locals.starlightRoute;
	const url = new URL(image.path, context.site ?? context.url).href;

	route.head.push(
		{ tag: 'meta', attrs: { property: 'og:image', content: url } },
		{ tag: 'meta', attrs: { property: 'og:image:type', content: 'image/jpeg' } },
		{ tag: 'meta', attrs: { property: 'og:image:width', content: image.width } },
		{ tag: 'meta', attrs: { property: 'og:image:height', content: image.height } },
		{ tag: 'meta', attrs: { property: 'og:image:alt', content: image.alt } },
		{ tag: 'meta', attrs: { name: 'twitter:image', content: url } },
		{ tag: 'meta', attrs: { name: 'twitter:image:alt', content: image.alt } },
	);

	if (route.id === '') {
		for (const entry of route.head) {
			if (entry.tag === 'title') entry.content = homeTitle;
			if (entry.attrs?.property === 'og:title') entry.attrs.content = homeTitle;
			if (entry.attrs?.property === 'og:type') entry.attrs.content = 'website';
		}
	}
});
