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
holds the brand (`docs/design/15-brand.md` and `docs/design/tokens.json` there). After a
brand change, with the app checked out beside this repository:

```
npm run sync-brand
```

It rewrites `src/styles/brand.css`, the mark and lockup in `src/assets`, the favicon and
the Newsreader font in `public/`. Commit the result. Set `NORTHLIGHT_APP_DIR` if the app
checkout is somewhere else. Site-only styling lives in `src/styles/theme.css`.
