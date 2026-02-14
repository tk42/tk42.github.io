---
name: url-reader
description: Read and summarize content from URLs shared in chat
---

**IMPORTANT: This skill MUST be applied automatically whenever a URL (http:// or https://) is detected in any user message.**

Fetch the URL content and summarize it in Japanese.

## Special handling for blocked sites

Some sites block direct fetch. Use these proxy/alternative URLs:

| Original domain | Replace with    | Notes                          |
| --------------- | --------------- | ------------------------------ |
| `x.com`         | `fixupx.com`    | Twitter/X embed-friendly proxy |
| `twitter.com`   | `fxtwitter.com` | Same as above                  |

## Fetch strategy (preferred order)

1. **Try `web_fetch`** if it is available in the runtime.
2. **Fallback: use `exec` + `curl -L`** to retrieve content.

### Qiita-specific tip

Qiita articles often expose raw Markdown by appending `.md`:

- `https://qiita.com/<user>/items/<id>` → try `https://qiita.com/<user>/items/<id>.md`

When the domain is `qiita.com` and the path matches `/items/<id>`, try the `.md` URL first.

## Workflow

1. Detect URL(s) in the user's message.
2. Rewrite blocked domains using the table above.
3. Fetch content:
   - First try `web_fetch`.
   - If it fails or is unavailable, run:
     - `curl -L -sS <url>`
     - If the output looks like HTML and the site provides a Markdown endpoint (e.g., Qiita `.md`), try that.
4. Summarize in Japanese, including:
   - 投稿者名（分かる範囲で）
   - 本文の要約（箇条書き推奨）
   - 重要なリンクや引用
   - 画像があれば説明
5. If you still cannot fetch content (paywall/blocked), ask the user to paste the text.

## Notes

- Always attempt to fetch before saying「読めない」
- For paywalled sites (e.g., Nikkei, WSJ), state that it is paywalled
- For PDFs, try fetching directly (often accessible)
