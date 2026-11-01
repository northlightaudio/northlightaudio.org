# northlightaudio.org

The website for [Northlight](https://github.com/northlightaudio/northlight), built with
[Astro](https://astro.build) and [Starlight](https://starlight.astro.build).

## Working on it

Requires Node.js 22 or later.

```sh
npm install
npm run dev      # a local preview at http://localhost:4321
npm run build    # the site in dist/
```

Pages are Markdown and MDX files in `src/content/docs/`; the sidebar is set in
`astro.config.mjs`, and the colours (from the application's design tokens) in
`src/styles/theme.css`.

## Publishing

Every push to `main` builds the site and publishes it to GitHub Pages
(`.github/workflows/deploy.yml`) at the domain in `public/CNAME`. On GitHub's free plan,
Pages needs this repository to be public. In the repository's settings, set Pages to
deploy from GitHub Actions, and point the domain's DNS at GitHub Pages.

## News

News posts are pages in `src/content/docs/news/`, with `template: splash` and a
`date` in their frontmatter; the news page (`/news/`) lists them newest first, and the
date shows under the title. `draft: true` keeps a post out of the published site until
it's ready.

## The manual

The user manual lives in the application repository, in `docs/manual/`, so it's
versioned with the code (its README there says how to write it). `astro.config.mjs`
copies it into `src/content/docs/manual/` whenever the site starts or builds
(`scripts/sync-manual.mjs`), and in `npm run dev` it copies again as you edit the
manual. The copy isn't committed. It looks for the app checkout at `../northlight` or
`../aural`; set `NORTHLIGHT_APP_DIR` if it's somewhere else. Without one, the manual is
a placeholder page. A new section in the manual's `sidebar.json` needs a restart of
the dev server.

Pages marked `draft: true` show in dev but aren't published, and a section with only
drafts is left out of the sidebar.

The deploy workflow checks out the app at its latest release's tag, or `main` before
the first release, and builds the site from that. Run the workflow by hand (Actions,
Deploy to GitHub Pages, Run workflow) to publish a manual change without a change
here.

## Brand

Colours, fonts, the logo and the favicon come from the application repository, which
holds the brand (`docs/design/brand.md` and `docs/design/tokens.json` there). After a
brand change, with the app checked out beside this repository:

```
npm run sync-brand
```

It rewrites `src/styles/brand.css`, the mark and lockup in `src/assets`, the favicon and
the Newsreader font in `public/`. Commit the result. Set `NORTHLIGHT_APP_DIR` if the app
checkout is somewhere else. Site-only styling lives in `src/styles/theme.css`.

## Screenshots

The screenshots in `src/assets/screenshots/` come from the app's capture mode
(`--capture`), which saves its window and named parts of it (the mixer, the channel
strip, an instrument's editor) at 2x while the demo song plays silently. When the
app's design changes, rebuild the app, then regenerate them and the press kit:

```
powershell -File scripts/screenshots.ps1
```

It uses the newest `Northlight.exe` in the app checkout's `build` folder (or `-Exe`).
The vocal pitch editing shot needs a sung recording: pass one with `-Vocal` (and the
key with `-Key`), or that screenshot is left as it is. Check the images before
committing them.

## Press kit

The press kit page (`src/content/docs/press.mdx`) links to files in `public/press/`:
the logo files and app icons from the application repository, PNG renders of the
logos, the screenshots from `src/assets/screenshots/`, and a zip of all of it. After a
brand change or a new screenshot, rebuild them (it needs Microsoft Edge to render the
PNGs) and commit the result:

```
powershell -File scripts/press-kit.ps1
```

## Share image

`public/og-image.jpg` (1200 x 630) is the picture shown when a page is shared on social
media or in chat; `src/routeData.ts` adds it to every page's Open Graph tags, along with
the home page's title. It's rendered from `scripts/og-image.html` with Microsoft Edge.
After changing the template, the logo or the photograph:

```
powershell -File scripts/og-image.ps1
```
