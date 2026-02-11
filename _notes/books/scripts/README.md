# 書影ダウンロードスクリプト

## 概要

2025年または2026年の日付を持つMarkdownファイルから書影のURLを収集し、画像をダウンロードするスクリプトです。

## 使い方

### 実行方法

```bash
cd /Users/jimako/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/tk42.github.io/_notes/books/scripts
python3 download_book_covers.py
```

または

```bash
./download_book_covers.py
```

### 動作内容

1. `books`ディレクトリ内のすべての`.md`ファイルを検索
2. 各ファイルの3行目の`date:`フィールドをチェック
3. 日付が2025または2026で始まる場合、書影URLを抽出
4. 書影URLから画像をダウンロードし、`covers`ディレクトリに保存

### 出力先

ダウンロードされた画像は以下のディレクトリに保存されます：

```
/Users/jimako/Library/Mobile Documents/iCloud~md~obsidian/Documents/tk42.github.io/_notes/books/covers/
```

### ファイル名の形式

```
YYYY-MM-DD_タイトル.jpg
```

例：
```
2025-01-19_世界の一流は「雑談」で何を話しているのか - ピョートル・フェリクス・グジバチ.jpg
2026-01-01_BC1177 古代グローバル文明の崩壊 - エリック・H・クライン.jpg
```

## 特徴

- 既にダウンロード済みの画像はスキップ
- ファイル名に使えない文字を自動的に置換
- ダウンロード結果のサマリーを表示

## 必要な環境

- Python 3.6以上
- 標準ライブラリのみ使用（追加のインストールは不要）
