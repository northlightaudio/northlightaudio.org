// Copies the user manual from the application repository (docs/manual) into
// src/content/docs/manual, where Starlight publishes it. astro.config.mjs runs this on
// every dev start and build, and in dev it re-copies when the manual changes.
//
//   node scripts/sync-manual.mjs                          (app checkout at ../northlight or ../aural)
//   NORTHLIGHT_APP_DIR=path node scripts/sync-manual.mjs  (anywhere else)
//
// The copy is not committed. Write the manual in the app repository; see its
// docs/manual/README.md.
//
// On the way, links between pages (`../recording/takes.md#comping`) become site
// addresses (`/manual/recording/takes/#comping`), so they work both on GitHub and here.
// Without an app checkout the manual is a placeholder page, except in CI, where that
// is an error.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const site = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const target = path.join(site, 'src/content/docs/manual');
const github = 'https://github.com/northlightaudio/northlight';

// Files in docs/manual that are for the repository, not the site.
const notPublished = new Set(['README.md', 'sidebar.json']);

export function findManual() {
	const candidates = [process.env.NORTHLIGHT_APP_DIR, '../northlight', '../aural']
		.filter(Boolean)
		.map((p) => path.resolve(site, p));
	const app = candidates.find((p) => fs.existsSync(path.join(p, 'docs/manual/sidebar.json')));
	return { dir: app ? path.join(app, 'docs/manual') : null, tried: candidates };
}

/**
 * Copies the manual and returns its sections in order, each with whether it has a
 * published (non-draft) page.
 * @returns {{ label: string, directory: string, published: boolean }[]}
 */
export function syncManual({ quiet = false } = {}) {
	const { dir: source, tried } = findManual();
	fs.rmSync(target, { recursive: true, force: true });
	fs.mkdirSync(target, { recursive: true });

	if (!source) {
		const message = `No Northlight checkout with a manual found (tried ${tried.join(', ')}). Set NORTHLIGHT_APP_DIR.`;
		if (process.env.CI) throw new Error(message);
		console.warn(`[sync-manual] ${message} Using a placeholder.`);
		fs.writeFileSync(
			path.join(target, 'index.md'),
			'---\ntitle: The manual\ndescription: How to use Northlight.\n---\n\n' +
				'The manual comes from the Northlight repository, and no checkout of it was found ' +
				'beside this one. Clone it next to this repository, or set `NORTHLIGHT_APP_DIR`.\n',
		);
		return [];
	}

	const pages = [];
	const missing = [];
	copyTree(source, target, pages);
	for (const page of pages) rewriteLinks(page, source, missing);
	for (const m of missing) console.warn(`[sync-manual] ${m}`);

	const sections = JSON.parse(fs.readFileSync(path.join(source, 'sidebar.json'), 'utf8'));
	const result = sections.map(({ label, directory }) => {
		const files = pages.filter((p) => p.rel.startsWith(`${directory}/`));
		if (files.length === 0) console.warn(`[sync-manual] sidebar.json lists ${directory}, which has no pages.`);
		return { label, directory, published: files.some((p) => !isDraft(p.text)) };
	});
	if (!quiet) {
		const published = pages.filter((p) => !isDraft(p.text)).length;
		console.log(`[sync-manual] ${pages.length} pages (${published} published) from ${source}`);
	}
	return result;
}

function copyTree(from, to, pages, rel = '') {
	for (const entry of fs.readdirSync(from, { withFileTypes: true })) {
		const name = entry.name;
		const relPath = rel ? `${rel}/${name}` : name;
		if (!rel && notPublished.has(name)) continue;
		if (name.startsWith('.')) continue;
		const src = path.join(from, name);
		const dst = path.join(to, name);
		if (entry.isDirectory()) {
			fs.mkdirSync(dst, { recursive: true });
			copyTree(src, dst, pages, relPath);
		} else if (/\.mdx?$/.test(name)) {
			pages.push({ rel: relPath, dst, text: fs.readFileSync(src, 'utf8') });
		} else {
			fs.copyFileSync(src, dst);
		}
	}
}

function isDraft(text) {
	const front = text.match(/^---\r?\n([\s\S]*?)\r?\n---/);
	return !!front && /^draft:\s*true\s*$/m.test(front[1]);
}

/** `recording/takes.md` → `/manual/recording/takes/`; `pitch/index.md` → `/manual/pitch/`. */
function route(rel) {
	const slug = rel.replace(/\.mdx?$/, '').replace(/(^|\/)index$/, '');
	return `/manual/${slug}${slug ? '/' : ''}`;
}

// Inline links and images [text](target) and reference definitions [id]: target.
const inlineLink = /(\]\()([^)\s]+)(\))/g;
const referenceLink = /^(\s*\[[^\]]+\]:\s*)(\S+)()/gm;

function rewriteLinks(page, source, missing) {
	const fromDir = path.posix.dirname(page.rel);
	const fix = (whole, before, href, after) => {
		const [file, hash = ''] = href.split(/(?=#)/);
		if (!/\.mdx?$/.test(file) || /^[a-z]+:|^\//i.test(file)) return whole;
		const rel = path.posix.normalize(path.posix.join(fromDir, file));
		if (rel.startsWith('..')) {
			// Elsewhere in the app repository's docs: link to it on GitHub.
			const docs = path.posix.normalize(path.posix.join('docs/manual', rel));
			return `${before}${github}/blob/${process.env.NORTHLIGHT_MANUAL_REF || 'main'}/${docs}${hash}${after}`;
		}
		if (!fs.existsSync(path.join(source, rel))) missing.push(`${page.rel} links to ${file}, which does not exist.`);
		return `${before}${route(rel)}${hash}${after}`;
	};
	let text = page.text.replace(inlineLink, fix).replace(referenceLink, fix);
	// "Edit page" goes to the page's source in the app repository, not to this copy.
	if (!/^editUrl:/m.test(text.split(/\r?\n---/)[0])) {
		text = text.replace(/^---\r?\n/, `---\neditUrl: ${github}/edit/main/docs/manual/${page.rel}\n`);
	}
	fs.writeFileSync(page.dst, text);
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
	syncManual();
}
