#!/usr/bin/env bash
# -------------------------------------------------------------
# ハンズオン資料ビルドスクリプト
#   入力: guides/handson-guide.md + assets/*.png
#   出力: dist/handson-guide.html  (画像埋込・単一ファイル)
# 実行: ./scripts/build.sh
# -------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SRC_MD="guides/handson-guide.md"
SRC_ASSETS="assets"
BUILD_DIR="build"
DIST_DIR="dist"
CSS="$DIST_DIR/style.css"
OUT="$DIST_DIR/handson-guide.html"

# ---- 前提チェック ---------------------------------------------------
command -v pandoc >/dev/null || { echo "❌ pandoc が見つかりません。brew install pandoc"; exit 1; }
command -v sips   >/dev/null || { echo "❌ sips が見つかりません (macOS標準)"; exit 1; }
[[ -f "$SRC_MD"  ]] || { echo "❌ $SRC_MD が見つかりません"; exit 1; }
[[ -f "$CSS"     ]] || { echo "❌ $CSS が見つかりません"; exit 1; }

mkdir -p "$BUILD_DIR/assets" "$BUILD_DIR/guides" "$DIST_DIR"

# ---- 1. 画像圧縮 (assets/*.png → build/assets/*.jpg) ----------------
# 元画像が新しい or 出力が無いものだけ処理 (差分ビルド)
echo "▸ 画像を圧縮中..."
count=0
for f in "$SRC_ASSETS"/*.png; do
  [[ -e "$f" ]] || continue
  name=$(basename "$f" .png)
  out="$BUILD_DIR/assets/${name}.jpg"
  if [[ ! -f "$out" || "$f" -nt "$out" ]]; then
    sips -Z 1600 -s format jpeg -s formatOptions 82 "$f" --out "$out" >/dev/null
    count=$((count + 1))
  fi
done
# icon.jpg 等の .jpg はそのままコピー (差分)
for f in "$SRC_ASSETS"/*.jpg; do
  [[ -e "$f" ]] || continue
  name=$(basename "$f")
  out="$BUILD_DIR/assets/$name"
  if [[ ! -f "$out" || "$f" -nt "$out" ]]; then
    cp "$f" "$out"
    count=$((count + 1))
  fi
done
echo "  → $count 件更新 (build/assets)"

# ---- 2. Markdown の画像参照を .png → .jpg に書換え --------------------
echo "▸ Markdown を変換中..."
sed 's|\.\./assets/\([^)]*\)\.png|../assets/\1.jpg|g' "$SRC_MD" > "$BUILD_DIR/guides/handson-guide.md"

# ---- 3. pandoc で単一HTML生成 ---------------------------------------
echo "▸ HTML を生成中..."
pandoc "$BUILD_DIR/guides/handson-guide.md" \
  --standalone \
  --embed-resources \
  --resource-path="$BUILD_DIR/guides" \
  --syntax-highlighting=none \
  --metadata title="Claude Code ハンズオン会" \
  --metadata lang="ja" \
  --toc --toc-depth=2 \
  --css "$CSS" \
  -o "$OUT"

# ---- 4. 結果表示 ----------------------------------------------------
size=$(ls -lh "$OUT" | awk '{print $5}')
echo ""
echo "✅ 完了: $OUT ($size)"
echo "   ブラウザで開く: open $OUT"
