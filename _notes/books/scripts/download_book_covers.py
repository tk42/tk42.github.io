#!/usr/bin/env python3
"""
書影画像ダウンロードスクリプト
2025の日付を持つMarkdownファイルから書影URLを収集し、画像をダウンロードします。
"""

import os
import re
import urllib.request
import urllib.parse
import ssl
from pathlib import Path
from typing import List, Tuple, Optional


def extract_date_and_cover_url(md_file: Path) -> Optional[Tuple[str, str, str]]:
    """
    Markdownファイルから日付と書影URLを抽出

    Args:
        md_file: Markdownファイルのパス

    Returns:
        (date, title, cover_url)のタプル、または見つからない場合はNone
    """
    try:
        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # 3行目のdate:を抽出
        lines = content.split('\n')
        date = None
        for i, line in enumerate(lines[:10]):  # 最初の10行以内を探索
            if line.startswith('date:'):
                date = line.split('date:')[1].strip()
                break

        # 2025または2026でない場合はスキップ
        if not date or not (date.startswith('2025')):
            return None

        # タイトルを抽出
        title = None
        for line in lines[:10]:
            if line.startswith('title:'):
                title = line.split('title:')[1].strip()
                break

        # 書影URLを抽出 (![cover|200](URL)の形式)
        cover_pattern = r'!\[cover\|\d+\]\((https?://[^\)]+)\)'
        match = re.search(cover_pattern, content)

        if match and title and date:
            cover_url = match.group(1)
            return (date, title, cover_url)

        return None
    except Exception as e:
        print(f"Error processing {md_file}: {e}")
        return None


def download_image(url: str, save_path: Path) -> bool:
    """
    URLから画像をダウンロード

    Args:
        url: 画像のURL
        save_path: 保存先のパス

    Returns:
        成功した場合True、失敗した場合False
    """
    try:
        # User-Agentを設定してリクエスト
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        }
        req = urllib.request.Request(url, headers=headers)

        # SSL証明書の検証を無効化するコンテキスト（Amazon等のURL用）
        context = ssl._create_unverified_context()

        with urllib.request.urlopen(req, context=context) as response:
            with open(save_path, 'wb') as out_file:
                out_file.write(response.read())

        print(f"Downloaded: {save_path.name}")
        return True
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        return False


def sanitize_filename(filename: str) -> str:
    """
    ファイル名として使えない文字を除去

    Args:
        filename: 元のファイル名

    Returns:
        サニタイズされたファイル名
    """
    # ファイル名に使えない文字を置換
    invalid_chars = '<>:"/\\|?*'
    for char in invalid_chars:
        filename = filename.replace(char, '_')
    # 長すぎる場合は切り詰め
    if len(filename) > 200:
        filename = filename[:200]
    return filename


def main():
    """メイン処理"""
    # カレントディレクトリの設定
    books_dir = Path(__file__).parent.parent
    output_dir = books_dir / 'covers'

    # 出力ディレクトリを作成
    output_dir.mkdir(exist_ok=True)

    print(f"Searching for markdown files in: {books_dir}")
    print(f"Output directory: {output_dir}")
    print("-" * 60)

    # Markdownファイルを収集
    md_files = list(books_dir.glob('*.md'))
    print(f"Found {len(md_files)} markdown files")
    print("-" * 60)

    # 画像URLを収集してダウンロード
    downloaded_count = 0
    skipped_count = 0

    for md_file in md_files:
        result = extract_date_and_cover_url(md_file)

        if result:
            date, title, cover_url = result

            # ファイル名を生成 (日付_タイトル.jpg)
            safe_title = sanitize_filename(title)
            filename = f"{date}_{safe_title}.jpg"
            save_path = output_dir / filename

            # 既にダウンロード済みの場合はスキップ
            if save_path.exists():
                print(f"Skipped (already exists): {filename}")
                skipped_count += 1
                continue

            print(f"Processing: {title} ({date})")
            print(f"  URL: {cover_url}")

            if download_image(cover_url, save_path):
                downloaded_count += 1

            print()

    print("-" * 60)
    print(f"Summary:")
    print(f"  Downloaded: {downloaded_count} files")
    print(f"  Skipped: {skipped_count} files")
    print(f"  Total processed: {downloaded_count + skipped_count} files")


if __name__ == '__main__':
    main()
