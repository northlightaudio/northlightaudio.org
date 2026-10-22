// The site's links, shared by the header, the mobile menus and the footer.

export interface NavLink {
	label: string;
	href: string;
}

export const github = 'https://github.com/northlightaudio/northlight';

/** The header's links. Download is a button beside them. */
export const primaryNav: NavLink[] = [
	{ label: 'Features', href: '/#features' },
	{ label: 'Manual', href: '/manual/' },
	{ label: 'The pledge', href: '/pledge/' },
	{ label: 'Join in', href: '/contributing/' },
];

/** The footer's columns. */
export const footerNav: { title: string; links: NavLink[] }[] = [
	{
		title: 'Northlight',
		links: [
			{ label: 'Features', href: '/#features' },
			{ label: 'Download', href: '/download/' },
			{ label: 'System requirements', href: '/download/#system-requirements' },
			{ label: 'Manual', href: '/manual/' },
			{ label: 'Build it yourself', href: '/download/#build-it-yourself' },
		],
	},
	{
		title: 'Project',
		links: [
			{ label: 'The pledge', href: '/pledge/' },
			{ label: 'Licence', href: '/licence/' },
			{ label: 'Press kit', href: '/press/' },
		],
	},
	{
		title: 'Community',
		links: [
			{ label: 'Join in', href: '/contributing/' },
			{ label: 'Source code', href: github },
			{ label: 'Report a bug', href: `${github}/issues` },
			{ label: 'Discussions', href: `${github}/discussions` },
			{ label: 'Code of conduct', href: 'https://github.com/northlightaudio/.github/blob/main/CODE_OF_CONDUCT.md' },
		],
	},
];

/** Whether a header link points at the page being shown, or the section it's in. */
export function isCurrent(href: string, pathname: string): boolean {
	if (href.includes('#')) return false;
	return pathname === href || pathname.startsWith(href);
}
