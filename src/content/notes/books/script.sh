#!/bin/bash

# 検索パターンの定義
SEARCH_PATTERN="http://books.google.com/books/content"

# 出力ディレクトリの作成
OUTPUT_DIR="downloaded_images"
mkdir -p "$OUTPUT_DIR"

# ハッシュ生成関数（複数のコマンドに対応）
generate_hash() {
    local input="$1"
    if command -v md5sum >/dev/null 2>&1; then
        echo "$input" | md5sum | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
        echo "$input" | shasum -a 256 | cut -d' ' -f1
    elif command -v openssl >/dev/null 2>&1; then
        echo "$input" | openssl sha256 | cut -d' ' -f2
    else
        # フォールバック: URLの最後の部分を使用
        echo "$input" | sed 's/.*\///' | sed 's/[^a-zA-Z0-9]/_/g'
    fi
}

# Markdownファイルから画像URLを抽出してダウンロード
find . -maxdepth 1 -type f -name "*.md" | while read -r file; do
    echo "Processing file: $file"
    
    # grep で画像URLを抽出し、URLエンコードされた文字を考慮
    grep -o "${SEARCH_PATTERN}[^)]*" "$file" | while read -r url; do
        # URLから安全なファイル名を生成
        filename=$(generate_hash "$url")
        
        # 画像の拡張子を取得（デフォルトはjpg）
        extension=$(echo "$url" | grep -o "zoom=[^&]*" | grep -o "\.[^&]*$" || echo ".jpg")
        
        # ファイル名を組み立て
        output_file="${OUTPUT_DIR}/${filename}${extension}"
        
        # 画像をダウンロード（既存ファイルはスキップ）
        if [ ! -f "$output_file" ]; then
            echo "Downloading: $url"
            echo "Saving as: $output_file"
            
            # curlまたはwgetを使用してダウンロード
            if command -v curl >/dev/null 2>&1; then
                curl -s -L "$url" -o "$output_file"
            elif command -v wget >/dev/null 2>&1; then
                wget -q "$url" -O "$output_file"
            else
                echo "Error: Neither curl nor wget is available"
                exit 1
            fi
            
            # ダウンロード成功の確認
            if [ -s "$output_file" ]; then
                echo "Successfully downloaded: $output_file"
            else
                echo "Failed to download: $url"
                rm -f "$output_file"
            fi
            
            # ダウンロード間隔を設定（サーバーに負荷をかけないため）
            sleep 1
        else
            echo "File already exists: $output_file"
        fi
    done
done

echo "Download completed. Images saved in $OUTPUT_DIR directory."
