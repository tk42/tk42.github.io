# tk42.github.io

Personal portfolio & knowledge base — [tk42.jp](https://tk42.jp)

## Structure

```
├── src/
│   ├── content/
│   │   ├── memos/    # Categorized knowledge base
│   │   └── notes/    # Long-form articles & book notes
│   ├── components/
│   ├── layouts/
│   ├── pages/
│   ├── plugins/      # Custom remark wiki-link plugin
│   └── styles/
├── public/
├── astro.config.ts
└── package.json
```

## Development

```bash
yarn install
yarn dev        # http://localhost:4321
```

## Features

- **Content Collections** — Type-safe `notes` and `memos` with Zod schema validation
- **Wiki-links** — Obsidian-style `[[links]]` via custom remark plugin
- **Backlinks** — Automatic reverse-link calculation
- **KaTeX** — Math rendering via `remark-math` + `rehype-katex`
- **Search** — Full-text search powered by [pagefind](https://pagefind.app/)
- **Dark mode** — System-aware with manual toggle

## Deployment

Push to `main` triggers GitHub Actions → builds Astro site → deploys to GitHub Pages.

Content updates: add/edit `.md` files in `src/content/memos/` or `src/content/notes/` and push.

## License

MIT
