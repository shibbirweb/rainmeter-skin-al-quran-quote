# Wiki source

This folder is the **source of truth** for the project's [GitHub Wiki](https://github.com/shibbirweb/rainmeter-skin-al-quran-quote/wiki).

Do **not** edit the wiki through GitHub's web editor. Instead, edit the Markdown files here and push to
the default branch. A GitHub Action
([`.github/workflows/publish-wiki.yml`](../.github/workflows/publish-wiki.yml)) automatically copies these
pages into the wiki whenever any file in this folder changes. Editing on the web would be overwritten on
the next publish.

## Pages

Each `.md` file becomes one wiki page. The filename is the page title, with hyphens shown as spaces (for
example `Text-and-Appearance.md` becomes the "Text and Appearance" page). Special files:

- `Home.md` - the wiki landing page.
- `_Sidebar.md` - the navigation shown on every page.
- `_Footer.md` - the footer shown on every page.

Links between pages use the page name without the `.md`, for example `[Installation](Installation)`.

## First-time setup (once per repository)

A repository's wiki does not exist until it has at least one page. Before the auto-publish workflow can
run, create the wiki once:

1. Open the repository's **Wiki** tab on GitHub.
2. Click **Create the first page**, type anything, and save.

After that, every push that changes a file in this `wiki/` folder republishes the whole set automatically.
