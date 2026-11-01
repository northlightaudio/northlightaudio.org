// Which links bring people who download, without cookies or storage.
//
// A visitor who arrives from a tagged link (an ad or a post) has utm_source and
// utm_campaign in the address. GoatCounter counts the visit under that campaign.
// The links to the download page carry the same tags along, so the download page
// knows the campaign too, and a click on a download link (data-download) counts as
// a GoatCounter event named "download-<campaign>", or "download-direct" without one.
// GoatCounter keeps only the campaign and source from the address, so nothing else
// is passed on.

declare global {
	interface Window {
		goatcounter?: { count?: (vars: { path: string; title?: string; event?: boolean }) => void };
	}
}

const kept = ['utm_source', 'utm_campaign'];
const params = new URLSearchParams(location.search);
const tags = new URLSearchParams(kept.flatMap((key) => (params.has(key) ? [[key, params.get(key) ?? '']] : [])));

// Event names stay short and plain whatever is typed into the address.
const campaign = (params.get('utm_campaign') ?? '').replace(/[^\w-]/g, '').slice(0, 64) || 'direct';

if ([...tags].length > 0) {
	for (const link of document.querySelectorAll<HTMLAnchorElement>('a[href^="/download"]')) {
		const url = new URL(link.href);
		if (url.search) continue;
		url.search = tags.toString();
		link.href = url.pathname + url.search + url.hash;
	}
}

document.addEventListener('click', (event) => {
	const link = event.target instanceof Element ? event.target.closest('a[data-download]') : null;
	if (!link) return;
	window.goatcounter?.count?.({
		path: `download-${campaign}`,
		title: link.textContent?.trim() || 'Download',
		event: true,
	});
});

export {};
