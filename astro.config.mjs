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
			// Dark only for now: no theme picker, and the theme ignores the system setting.
			components: {
				ThemeProvider: './src/components/ThemeProvider.astro',
				ThemeSelect: './src/components/ThemeSelect.astro',
			},
			customCss: ['./src/styles/brand.css', './src/styles/theme.css'],
			head: [{ tag: 'link', attrs: { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' } }],
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/northlightaudio/northlight' }],
			editLink: { baseUrl: 'https://github.com/northlightaudio/northlightaudio.org/edit/main/' },
			sidebar: [
				{ label: 'Download', slug: 'download' },
				{
					label: 'Manual',
					items: [{ autogenerate: { directory: 'manual' } }],
				},
				{
					label: 'Project',
					items: [
						{ label: 'The pledge', slug: 'pledge' },
						{ label: 'Licence', slug: 'licence' },
						{ label: 'Join in', slug: 'contributing' },
						{ label: 'Press kit', slug: 'press' },
					],
				},
			],
		}),
	],
});
