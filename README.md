# TK42-Brain — Personal Life OS

A monorepo that manages **infrastructure (Terraform)**, **applications (Docker/OpenClaw)**, and **knowledge (Astro)** as a single source of truth for a self-hosted personal platform.

- **Domain**: [tk42.jp](https://tk42.jp)
- **Chat**: `chat.tk42.jp` (Mattermost)
- **Managed by**: tk42

## Repository Structure

```
├── data/            # Master data store
│   ├── memos/       #   ✅ public memos (→ site at build time)
│   ├── notes/       #   ✅ public articles (→ site at build time)
│   ├── template/    #   ✅ note templates
│   ├── idea/        #   🔒 private (idea channel → daily thoughts)
│   ├── project/     #   🔒 private (project management)
│   └── contracts/   #   🔒 private (legal documents)
├── site/            # Astro static site (TypeScript) → GitHub Pages
├── infra/           # Terraform (GCP VM + Cloudflare DNS + GCS backup)
├── apps/            # Docker Compose (Mattermost + PostgreSQL + Caddy + OpenClaw)
├── scripts/         # VM setup, DB backup & private data backup
└── .github/         # CI/CD workflows
```

### Data Flow

```
Mattermost channels → OpenClaw → data/ (master)
                                  ├─ memos/, notes/ → GitHub Actions → site/ → GitHub Pages
                                  └─ idea/, project/, contracts/ → GCS backup (cron)
```

## Quick Start

### Site (Local Development)

```bash
cd site
yarn install
yarn dev        # http://localhost:4321
```

### Infrastructure

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your credentials
terraform init
terraform plan
terraform apply
```

### Applications (on VM)

ssh connection

```bash
gcloud compute ssh tk42-brain --zone=us-central1-a --project=llm-server-447708
```

```bash
cd apps
cp .env.example .env
# Edit .env with your credentials
docker compose up -d
```

## Tech Stack

| Layer     | Technology               | Purpose                                |
| --------- | ------------------------ | -------------------------------------- |
| **Site**  | Astro (TypeScript)       | Static site generator, 0 JS by default |
| **Infra** | Terraform                | GCP VM, Cloudflare DNS                 |
| **Chat**  | Mattermost               | Conversational interface               |
| **AI**    | OpenClaw + Anthropic API | Knowledge automation                   |
| **DB**    | PostgreSQL               | Shared database                        |
| **Proxy** | Caddy                    | Automatic HTTPS                        |

## Site Features

- **Content Collections** — Type-safe `notes` and `memos` with Zod schema validation
- **Wiki-links** — Obsidian-style `[[links]]` via custom remark plugin (resolves to both notes and memos)
- **Backlinks** — Automatic reverse-link calculation in TypeScript
- **KaTeX** — Math rendering via `remark-math` + `rehype-katex`
- **Search** — Full-text search powered by [pagefind](https://pagefind.app/) (built at build time)
- **Dark mode** — System-aware with manual toggle

## Mattermost Channels

| Channel     | Action                                                    | Output            | Public |
| ----------- | --------------------------------------------------------- | ----------------- | ------ |
| `memos`     | Auto-categorize → Markdown                                | `data/memos/`     | Yes    |
| `note`      | Synthesize memos → Blog article                           | `data/notes/`     | Yes    |
| `idea`      | @brain で推敲・再投稿 → 良いものを memos ch に転送        | `data/idea/`      | No     |
| `project`   | CRUD project notes via chat, @brain で推敲                | `data/project/`   | No     |
| `receipts`  | Receipt image → OCR → confirm → PostgreSQL / budget query | PostgreSQL        | No     |
| `contracts` | Contract PDF → store / search / draft                     | `data/contracts/` | No     |

### Channel Workflow

```
idea ch      → @brain で推敲・再投稿 → 良いものを memos ch に転送
memos ch     → OpenClaw → data/memos/ → git push → GitHub Actions → site/memos/
note ch      → OpenClaw → data/notes/ → git push → GitHub Actions → site/notes/
project ch   → @brain で推敲、data/project/ の CRUD をチャットベースで実行
receipts ch  → レシート画像 → @brain OCR → 確認後 PostgreSQL 保存 / 家計簿クエリ
contracts ch → 契約書 PDF post → data/contracts/ 保存 / 過去検索 / 下書き生成
```

## OpenClaw + Mattermost

OpenClaw connects to Mattermost via the official **`@openclaw/mattermost`** extension plugin. The plugin is auto-installed on container startup (see `apps/docker-compose.yml`).

Key config (`apps/openclaw/config.json`):

- `channels.mattermost.chatmode: "onmessage"` — responds to every channel message
- `channels.mattermost.dmPolicy: "open"` — accepts all DMs
- `tools.exec` enabled with allowlist (`grep`, `find`, `cat`, `head`, `wc`, `ls`)
- Search skill (`apps/openclaw/skills/search.md`) enables knowledge base queries
- Each channel has a dedicated skill with its own prompt and output directory

Docs: https://docs.openclaw.ai/channels/mattermost

## Private Data Backup

Private directories (`data/idea/`, `data/project/`, `data/contracts/`) are excluded from Git via `.gitignore` and backed up to a GCS bucket (`NEARLINE` storage class) via `scripts/backup_private.sh`.

```bash
# Manual backup
./scripts/backup_private.sh llm-server-447708-brain-private

# Cron (daily at 3:00 AM on VM)
0 3 * * * /opt/brain/scripts/backup_private.sh llm-server-447708-brain-private

# One-shot upload of local private data to GCS
./scripts/upload_local_to_gcs.sh ./data llm-server-447708-brain-private
```

## License

MIT
