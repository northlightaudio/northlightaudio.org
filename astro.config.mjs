// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://northlightaudio.org',
	integrations: [
		starlight({
			title: 'Northlight',
			description: 'A free and open source digital audio workstation for Windows. Anyone can use it for anything, and anyone can read and change its code.',
			logo: { src: './src/assets/lockup-dark.svg', alt: 'Northlight', replacesTitle: true },
			favicon: '/favicon.svg',
			// The share image on every page and the home page's title (src/routeData.ts).
			routeMiddleware: './src/routeData.ts',
			components: {
				// Dark only for now: no theme picker, and the theme ignores the system setting.
				ThemeProvider: './src/components/ThemeProvider.astro',
				ThemeSelect: './src/components/ThemeSelect.astro',
				// A site header and footer instead of documentation chrome, and a home page
				// hero that leads with a screenshot. The links are in src/nav.ts.
				Header: './src/components/Header.astro',
				MobileMenuFooter: './src/components/MobileMenuFooter.astro',
				Footer: './src/components/Footer.astro',
				Hero: './src/components/Hero.astro',
			},
			customCss: ['./src/styles/brand.css', './src/styles/theme.css'],
			head: [
				{ tag: 'link', attrs: { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' } },
				// Visit counts and referrers with GoatCounter: no cookies, nothing that follows
				// visitors across sites. It does not count visits from localhost.
				{
					tag: 'script',
					attrs: {
						'data-goatcounter': 'https://northlightaudio.goatcounter.com/count',
						async: true,
						src: 'https://gc.zgo.at/count.js',
					},
				},
			],
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/northlightaudio/northlight' }],
			editLink: { baseUrl: 'https://github.com/northlightaudio/northlightaudio.org/edit/main/' },
			// Only the manual has a sidebar. The other pages use the splash template and
			// are reached from the header and footer.
			sidebar: [
				{
					label: 'Manual',
					items: [{ autogenerate: { directory: 'manual' } }],
				},
			],
		}),
	],
});
