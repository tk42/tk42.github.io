---
name: url-reader
description: Read and summarize content from URLs shared in chat
---

When a user shares a URL, use the `web_fetch` tool to retrieve its content and provide a summary.

## Special handling for blocked sites

Some sites block direct fetch. Use these proxy/alternative URLs:

| Original domain         | Replace with              | Notes                          |
| ----------------------- | ------------------------- | ------------------------------ |
| `x.com`                 | `fixupx.com`              | Twitter/X embed-friendly proxy |
| `twitter.com`           | `fxtwitter.com`           | Same as above                  |

### Example

- User posts: `https://x.com/user/status/123456`
- Fetch: `https://fixupx.com/user/status/123456`

## Workflow

1. Detect URL(s) in the user's message
2. If the domain matches a blocked site, rewrite the URL using the table above
3. Use `web_fetch` to retrieve the content
4. Summarize the content in Japanese, including:
   - 投稿者名
   - 本文の要約
   - 画像があれば説明
   - 重要なリンクや引用
5. If `web_fetch` fails even with the proxy, inform the user and ask them to paste the text directly

## Notes

- Always attempt to fetch before saying "読めない"
- For paywalled sites (e.g., Nikkei, WSJ), inform the user that the content is behind a paywall
- For PDF links, use `web_fetch` directly — most PDFs are accessible
