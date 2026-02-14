# TK42-Brain — 現状と残作業

2025-02-14 時点のプロジェクト状態を反映。

---

## 完了済み

| 項目                         | 状態                                                                                                                   |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Astro サイト (`site/`)       | ✅ Content Collections, ページルーティング, CSS, KaTeX, pagefind 検索, ダークモード                                    |
| GitHub Actions (`pages.yml`) | ✅ yarn 化, `data/memos/` → `site/src/content/memos/` rsync                                                            |
| Terraform (`infra/`)         | ✅ GCP VM, Cloudflare DNS, GCS バックアップバケット                                                                    |
| Docker Compose (`apps/`)     | ✅ Mattermost, PostgreSQL, Caddy, OpenClaw                                                                             |
| OpenClaw config              | ✅ 公式 `openclaw.json` 形式に変換、6チャンネル体系、バンドルスキル (github, summarize 等)                             |
| wiki-link プラグイン         | ✅ notes + memos 両方のスラグ解決、private データへのリンク防止                                                        |
| favicon                      | ✅ `site/public/favicon.png`                                                                                           |
| 画像配置                     | ✅ `data/memos/` 内の画像を `site/public/images/memos/` に配置、参照パス修正                                           |
| データ命名変更               | ✅ `data/resource/` → `data/memos/`, `data/diary/` → `data/idea/`, `data/area/` → project に統合, `data/archive/` 削除 |
| .gitignore                   | ✅ private: idea, project, contracts                                                                                   |
| README.md                    | ✅ 新命名体系を反映                                                                                                    |
| scripts                      | ✅ `backup_private.sh` 更新, `upload_local_to_gcs.sh` 新規                                                             |
| 非 .md ファイル整理          | ✅ `data/memos/` 内の画像・PDF を `site/public/images/memos/` に移動後、元ファイル削除                                 |
| 不要依存削除                 | ✅ `@portaljs/remark-wiki-link` を `package.json` から削除                                                             |
| Backlinks 精度               | ✅ `[[title]]` / `[[title\|` パターンに修正（誤マッチ防止）                                                            |
| setup_vm.sh                  | ✅ private ディレクトリ (idea, project, contracts) の `mkdir -p` 追加                                                  |
| 公式ツール有効化             | ✅ web_fetch, image, memory, sessions（web_search は無効、curl + DuckDuckGo で代替）                                   |
| 動的 DB 操作                 | ✅ receipts が `docker exec psql` で動的にテーブル作成・クエリ可能に（固定スキーマ不要）                               |

## データ構造

```
data/
├── memos/       ✅ public  → site/memos/   (Mattermost: memos ch)
├── notes/       ✅ public  → site/notes/   (Mattermost: note ch)
├── template/    ✅ public
├── idea/        🔒 private                 (Mattermost: idea ch)
├── project/     🔒 private                 (Mattermost: project ch)
└── contracts/   🔒 private                 (Mattermost: contracts ch)
```

## Mattermost チャンネル

| Channel     | 動作                                    | 出力先                 |
| ----------- | --------------------------------------- | ---------------------- |
| `memos`     | 公開メモ自動分類 → Markdown             | `data/memos/` → サイト |
| `note`      | メモ → ブログ記事合成                   | `data/notes/` → サイト |
| `idea`      | @brain で推敲 → 良いものを memos に転送 | `data/idea/`           |
| `project`   | プロジェクトノート CRUD                 | `data/project/`        |
| `receipts`  | レシート OCR → 確認 → PostgreSQL        | PostgreSQL             |
| `contracts` | 契約書保存・検索・下書き                | `data/contracts/`      |

## 残作業

### 高優先度（デプロイ前）

- [ ] Mattermost に新チャンネル作成 (idea, project, receipts, contracts)
- [ ] VM にデプロイして動作確認 (`terraform apply` → `docker compose up`)
- [ ] ローカルの private データを GCS にアップロード (`scripts/upload_local_to_gcs.sh`)

### 低優先度

- [ ] PagePreview.astro（ホバープレビュー）の改善
- [ ] サイトのパフォーマンス最適化
- [ ] Terraform の state 管理（remote backend）
- [ ] `backup.sh` にレシートデータ用ダンプ追加
