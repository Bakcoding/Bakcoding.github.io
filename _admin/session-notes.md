# Session Notes

Date: 2026-07-03

## Project

- Root workspace: `/Users/bak/Desktop/GitBlog`
- Actual blog project: `/Users/bak/Desktop/GitBlog/Bakcoding.github.io`
- Repository: `https://github.com/Bakcoding/Bakcoding.github.io.git`
- Branch: `master`
- Stack: GitHub Pages, Jekyll, Minimal Mistakes
- Site title: `박코딩 블로그`

## Goal

Make the existing GitHub Pages + Jekyll blog easier to maintain with Codex.
The first focus is page/post management, starting with consistent post file names.

## Decisions

Post file names should follow this rule:

```text
YYYY-MM-DD-main-sub-NNN-slug.md
```

Rules:

- Use lowercase ASCII.
- Use hyphens as separators.
- Avoid spaces, underscores, commas, and trailing punctuation.
- Keep the Jekyll required date prefix.
- Use `basic` as the default sub category when the old file name had no clear sub category.
- Keep the sequence number as three digits.

Examples:

```text
2021-06-22-c-basic-001-helloworld.md
2022-03-15-network-mirror-001-mirror.md
2022-08-21-blog-memo-001-developer-english-intro.md
```

## Completed

- Confirmed `/Users/bak/Desktop/GitBlog` is not a Git repo itself.
- Confirmed `Bakcoding.github.io` is the actual Git repository.
- Renamed 288 files under `_posts` with `git mv`.
- Confirmed post count remains 302.
- Confirmed all `_posts` file names match the chosen rule.
- Confirmed no `_posts` file names contain spaces or underscores.
- Confirmed no `_posts` file names end with `untitled`.
- Compared old and new URLs after the rename.
- Found that 264 of 302 post URLs would change without additional handling.
- Added explicit `permalink` values to 264 posts to preserve their old public URLs.
- Rechecked URL comparison and confirmed `url_changed_after_permalink=0`.
- Fixed local build dependencies in `Gemfile`.
- Confirmed `bundle exec jekyll build` succeeds.
- Simplified the visible category UI using `_data/category_groups.yml`.
- Replaced the long hand-written sidebar category menu with a data-driven grouped menu.
- Replaced the `/categories/` archive layout with a grouped category hub.
- Chose `Game Development` as the group name for Unity, Mirror, Cocos, and ThreeBullets.
- Added post templates under `_templates/`.
- Added reusable post media styles in `_sass/minimal-mistakes/_post-media.scss`.
- Excluded `_templates` from Jekyll output.
- Added `scripts/new_post.rb` to generate posts from the new rules.
- Verified `scripts/new_post.rb` with `--dry-run` for Programming and Game Development posts.
- Added Nanum Gothic as the primary web font while keeping the existing monospace code font.
- Changed the sidebar category menu to a collapsible grouped menu.
- The sidebar now shows only top-level category groups by default; clicking a group expands its child categories.
- Implemented this with native `<details>/<summary>` markup in `_includes/nav_list_main` and styles in `_sass/minimal-mistakes/_category-nav.scss`.
- Fixed the broken visitor counter badge.
- The old `hits.seeyoufarm.com/api/count/incr/badge.svg` URL returned HTTP 404.
- Replaced it with a working `hits.sh` SVG badge in `_includes/sidebar.html`.
- Added `_sass/minimal-mistakes/_visitor-counter.scss` for the badge styling.
- Added a custom `bakcoding` Minimal Mistakes skin for the blog's light mode.
- Changed `minimal_mistakes_skin` from `dark` to `bakcoding`.
- Added `_sass/minimal-mistakes/_color-modes.scss` to support automatic dark mode via `prefers-color-scheme`.
- Light mode uses a clean off-white/charcoal/teal palette.
- Dark mode uses a softer charcoal and muted green-teal palette for lower eye strain.
- Updated text, links, borders, navigation, code blocks, tables, footer, sidebar, and mobile menu colors for both modes.
- Installed GitHub CLI with Homebrew for device/mobile authentication.
- Authenticated GitHub CLI as `Bakcoding` with device login.
- Committed all blog operation/theme changes:
  `887d04ee Improve blog authoring and theme`
- Pushed `master` to `origin`.
- GitHub Pages source is `master` at `/`.
- GitHub Pages URL is `https://bakcoding.github.io/`.
- GitHub Pages API reported status `building` immediately after the push.

## Important Risk

The site currently uses this permalink:

```yaml
permalink: /:categories/:title/
```

Because `:title` can derive from the file slug, renaming post files can change post URLs.
This was handled by adding explicit `permalink` values to affected posts.

Going forward:

- Treat file names as internal management identifiers.
- Treat front matter `permalink` as the stable public URL.
- When renaming an existing post, keep or add `permalink` so the URL does not change.
- Treat `_data/category_groups.yml` as the source of truth for visible category grouping.

## Build Status

`bundle exec jekyll build` now succeeds.

The local build required these Gemfile adjustments:

- `webrick`, because `>= 2.2.8` did not exist in available gem sources.
- `ffi`, because the latest resolved version required Ruby 3 while the local Ruby is 2.6.
- `jekyll-sass-converter`, because version 3 pulled in `sass-embedded`, which failed in this local environment.

Build command used:

```bash
env SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX12.3.sdk bundle exec jekyll build
```

## New Post Templates

- `_templates/post-study.md`: default study/information post template.
- `_templates/post-memo.md`: shorter memo post template.

Templates are local source files and are excluded from Jekyll output.

## New Post Command

Example:

```bash
ruby scripts/new_post.rb --title "C# 델리게이트 기본" --category Programming --tags CSharp,Delegate --sub csharp --slug csharp-delegate-basic
```

Use `--dry-run` to preview without writing files.

The script:

- Generates `_posts/YYYY-MM-DD-main-sub-NNN-slug.md`.
- Adds stable `permalink`.
- Uses top-level categories from `_data/category_groups.yml`.
- Creates the dated image directory under `assets/images/posts/YYYY/MM/DD/`.

## How To Resume

Ask Codex:

```text
_admin/session-notes.md 읽고 이전 작업 이어서 진행해줘
```

## 2026-07-04 Tistory Migration

- Source blog: `https://b-note.tistory.com/`
- Imported the `Program Language` category first.
- Excluded categories requested by the user for future migration: `Life`, `Memo`.
- Created `scripts/import_tistory.rb` for repeatable Tistory migration.
- Imported 71 posts into `_posts`.
- Copied 50 visible article images into `assets/images/posts/YYYY/MM/DD/`.
- Preserved source publish dates in imported post filenames, `date`, and `last_modified_at`.
- Added `source_url` front matter to imported posts for duplicate detection.
- Category mapping used:
  - `Program Language/C#` -> `CSharp`
  - `Program Language/Python` -> `Python`
  - `Program Language/JavaScript` -> `Javascript`
  - parent `Program Language` concept posts -> `ProgrammingBasic`
- Added visible category menu items:
  - `Python`
  - `Programming Basics`
- Removed Tistory remote image references from visible imported post images.
- Verified imported source count:
  `rg -n "source_url: https://b-note.tistory.com/" _posts/*programming-* | wc -l` -> `71`
- Verified build:
  `bundle exec jekyll build` succeeded without warnings.

## 2026-07-04 Deployment Notes

- Deployed final blog changes to `origin/master`.
- Final deployed commit: `a9631ccb` (`Trigger Pages deployment`).
- GitHub Pages run `28709338073` completed successfully.
- Local production build also passed:
  `JEKYLL_ENV=production bundle exec jekyll build`
- Large imported image/GIF assets caused HTTPS push failures. To complete deployment:
  - Replaced oversized image references with source-post links in the affected posts.
  - Excluded oversized assets from the deployed commit history.
  - Pushed remaining imported images in small batches.
- Local `master` now matches `origin/master`.
- Preserved the earlier single large unpushed commit as local branch `master-unsplit-backup`.

## 2026-07-04 Google Analytics

- Added Google Analytics 4 through Minimal Mistakes `google-gtag` provider.
- GA4 stream ID provided by user: `12223407756`
- GA4 measurement ID configured in `_config.yml`: `G-F6583GZWKG`
- Enabled `anonymize_ip: true`.
- Verified production build:
  `JEKYLL_ENV=production bundle exec jekyll build`
- Verified generated `_site/index.html` includes:
  - `https://www.googletagmanager.com/gtag/js?id=G-F6583GZWKG`
  - `gtag('config', 'G-F6583GZWKG', { 'anonymize_ip': true});`

## 2026-07-04 Theme Toggle

- Added a top masthead color mode toggle button.
- Toggle cycle:
  `auto` -> `light` -> `dark` -> `auto`
- Stored manual selection in `localStorage` key:
  `bakcoding-theme`
- Added an early head script in `_includes/head/custom.html` to apply saved theme before page paint.
- Added `assets/js/theme-toggle.js` and registered it through `_config.yml` `after_footer_scripts`.
- Extended `_sass/minimal-mistakes/_color-modes.scss` so manual `html[data-theme="light"]` and `html[data-theme="dark"]` modes work alongside system `prefers-color-scheme`.
- Added header button styles and icon switching for system/light/dark modes.
- Verified JavaScript syntax:
  `node --check assets/js/theme-toggle.js`
- Verified build:
  `bundle exec jekyll build` succeeded without warnings.

## 2026-07-04 Tistory Coding Migration

- Imported the `Coding` category from `https://b-note.tistory.com/`.
- Imported 36 posts into `_posts`.
- Added 11 more visible article images under `assets/images/posts/YYYY/MM/DD/`.
- Preserved source publish dates in imported post filenames, `date`, and `last_modified_at`.
- Extended `scripts/import_tistory.rb` to support the `coding` target.
- Category mapping used:
  - `Coding/Algorithm` -> `Algorithm`
  - `Coding/Coding Test` -> `CodingTest`
- Added `CodingTest` to the visible `Coding Test` category menu item.
- Removed Tistory remote image references from visible imported post images.
- Verified imported source count:
  `rg -n "source_url: https://b-note.tistory.com/" _posts/*coding-* | wc -l` -> `36`
- Total imported Tistory post count after this step:
  `Program Language` 71 + `Computer` 15 + `Develop` 41 + `Coding` 36 = `163`
- Verified build:
  `bundle exec jekyll build` succeeded without warnings.

## 2026-07-04 Tistory Develop Migration

- Imported the `Develop` category from `https://b-note.tistory.com/`.
- Imported 41 posts into `_posts`.
- Added 298 more visible article images under `assets/images/posts/YYYY/MM/DD/`.
- Preserved source publish dates in imported post filenames, `date`, and `last_modified_at`.
- Extended `scripts/import_tistory.rb` to support the `develop` target.
- Category mapping used:
  - `Develop/Unity` -> `Unity`
  - `Develop/Unreal` -> `Unreal`
  - `Develop/Server` -> `Server`
  - `Develop/Flutter` -> `Flutter`
- Added visible category menu items:
  - `Unreal` under `Game Development`
  - `Flutter` under `Programming`
  - `Server` under `Tools`
- Removed Tistory remote image references from visible imported post images and video thumbnail metadata.
- Verified imported source count:
  `rg -n "source_url: https://b-note.tistory.com/" _posts/*develop-* | wc -l` -> `41`
- Total imported Tistory post count after this step:
  `Program Language` 71 + `Computer` 15 + `Develop` 41 = `127`
- Verified build:
  `bundle exec jekyll build` succeeded without warnings.

## 2026-07-04 Tistory Computer Migration

- Imported the `Computer` category from `https://b-note.tistory.com/`.
- Imported 15 posts into `_posts`.
- Added 27 more visible article images under `assets/images/posts/YYYY/MM/DD/`.
- Preserved source publish dates in imported post filenames, `date`, and `last_modified_at`.
- Extended `scripts/import_tistory.rb` to support migration targets:
  - `program-language`
  - `computer`
- Category mapping used:
  - `Computer/Engineering` -> `ComputerEngineering`
  - `Computer/Network` -> `Network`
  - `Computer/Graphics` -> `Graphics`
  - parent `Computer` algorithm/pathfinding posts -> `ComputerAlgorithm`
- Added visible category menu items:
  - `Engineering`
  - `CS Algorithms`
- Added `Graphics` to the existing `Graphics` menu category mapping.
- Verified imported source count:
  `rg -n "source_url: https://b-note.tistory.com/" _posts/*computer-science-* | wc -l` -> `15`
- Verified build:
  `bundle exec jekyll build` succeeded without warnings.
