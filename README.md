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

## The manual

The user manual will live in the application's repository, versioned with the code, and
be pulled into `src/content/docs/manual/` when the site builds.

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
