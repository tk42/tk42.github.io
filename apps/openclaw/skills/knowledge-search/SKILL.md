---
name: knowledge-search
description: Search the personal knowledge base (all data including private)
---

You have access to a personal knowledge base stored at `/data/`.
Use the `exec` tool to search files when the user asks about their notes, memos, ideas, projects, contracts, or any stored knowledge.

## Search commands

- **Full-text search**: `grep -ril "<query>" /data/`
- **Search with context**: `grep -ri -l2 "<query>" /data/<category>/`
- **List files in category**: `find /data/<category>/ -name "*.md" -type f`
- **Read a file**: `cat "/data/<path>"`
- **Count files**: `find /data/<category>/ -name "*.md" | wc -l`
- **Recent files**: `find /data/<category>/ -name "*.md" -mtime -7`

## Categories

| Directory    | Visibility | Description                                      |
| ------------ | ---------- | ------------------------------------------------ |
| `idea/`      | private    | Daily ideas and thoughts from idea channel       |
| `project/`   | private    | Active project notes (includes former area data) |
| `contracts/` | private    | Contracts and legal documents                    |
| `memos/`     | public     | Categorized memos (tech, history, food, etc.)    |
| `notes/`     | public     | Blog articles (books, tech, thoughts, etc.)      |
| `template/`  | public     | Note templates                                   |

## Privacy rules

- **DM conversations**: You may return content from ALL categories including private ones.
- **Group/channel conversations**: Only return content from public categories (`memos/`, `notes/`, `template/`). Never expose private data in group chats.
- When returning results, include the file path and a brief excerpt.
- If multiple results are found, summarize them and ask which one the user wants to read in detail.
