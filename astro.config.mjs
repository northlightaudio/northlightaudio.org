// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://northlightaudio.org',
	integrations: [
		starlight({
			title: 'Northlight',
			description: 'A native digital audio workstation for Windows. Free software under the GNU AGPLv3.',
			logo: { dark: './src/assets/lockup-dark.svg', light: './src/assets/lockup-light.svg', alt: 'Northlight', replacesTitle: true },
			favicon: '/favicon.svg',
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
						{ label: 'Licence', slug: 'licence' },
						{ label: 'Contributing', slug: 'contributing' },
					],
				},
			],
		}),
	],
});
