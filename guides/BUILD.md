# ハンズオン資料のビルド手順

`guides/handson-guide.md` を編集したあと、配布用の単一HTMLファイル `dist/handson-guide.html` を生成する方法です。

## 📦 配布物

- **`dist/handson-guide.html`** — 参加者に配布する単一HTMLファイル(画像埋込・約8MB)
- これ1ファイルで完結。オフラインでも閲覧可能、メール添付・AirDrop・Google Drive 共有OK

## ⚡ ワンコマンドで再生成

```bash
./scripts/build.sh
```

これだけで以下を全部自動でやってくれます:

1. `assets/*.png` をリサイズ(横1600px)+JPEG変換して `build/assets/` に圧縮版を作成 (差分ビルド)
2. `guides/handson-guide.md` の画像参照 `.png` → `.jpg` を書換えて `build/guides/` にコピー
3. `pandoc` で単一HTMLを生成して `dist/handson-guide.html` に出力

完了時にファイルサイズが表示されます。`open dist/handson-guide.html` でブラウザ確認できます。

## 🔄 よくある編集パターン

### テキストだけ変更した場合
```bash
./scripts/build.sh
```
画像は差分判定でスキップされるので数秒で完了します。

### 新しい画像を追加した場合
1. `assets/` に `.png` で画像を配置
2. `guides/handson-guide.md` に `![](../assets/ファイル名.png)` で参照を追加
3. `./scripts/build.sh` を実行
  - 新規追加・更新された画像だけ自動で圧縮されます

### デザイン(CSS)を変更した場合
1. `dist/style.css` を編集
2. `./scripts/build.sh` を実行

## 🛠 前提ツール

- **pandoc** — Markdown → HTML 変換
  ```bash
  brew install pandoc
  ```
- **sips** — 画像の圧縮・リサイズ(macOS標準なのでインストール不要)

## 📁 ディレクトリ構成

```
.
├── guides/
│   ├── handson-guide.md   ← ★編集するのはここ
│   └── BUILD.md           ← このファイル
├── assets/                 ← ★元画像(PNG)を置くのはここ
│   └── *.png
├── dist/
│   ├── style.css           ← ★デザインCSS
│   └── handson-guide.html  ← 📤 配布物(自動生成)
├── build/                  ← 中間生成物(.gitignore対象、削除OK)
│   ├── assets/*.jpg        ← 圧縮版画像
│   └── guides/             ← 参照書換え済みMD
└── scripts/
    └── build.sh            ← ビルドスクリプト
```

## 💡 手動でビルドしたい場合

スクリプトを使わず、コマンドを直接叩きたいとき:

```bash
# 1. 画像圧縮 (例: 1枚)
sips -Z 1600 -s format jpeg -s formatOptions 82 \
  assets/sample.png --out build/assets/sample.jpg

# 2. Markdownコピー + 参照書換え
sed 's|\.\./assets/\([^)]*\)\.png|../assets/\1.jpg|g' \
  guides/handson-guide.md > build/guides/handson-guide.md

# 3. pandoc でHTML生成
pandoc build/guides/handson-guide.md \
  --standalone \
  --embed-resources \
  --resource-path=build/guides \
  --syntax-highlighting=none \
  --metadata title="Claude Code ハンズオン会" \
  --metadata lang="ja" \
  --toc --toc-depth=2 \
  --css dist/style.css \
  -o dist/handson-guide.html
```

## ❓ トラブルシューティング

### 「画像が表示されない」とビルド時に WARNING が出る
原本MDに `![](../assets/foo.png)` と書いてあるが `assets/foo.png` が存在しない場合に出ます。
- 画像を追加するか、該当行を削除してください

### `build/` を消してしまった
問題ありません。`./scripts/build.sh` を実行すれば全画像を再圧縮してくれます (初回は時間が少しかかります)。

### `assets/` の元画像を更新したのに反映されない
差分判定はファイルのタイムスタンプ(`mtime`)で行っています。`touch assets/更新したファイル.png` してから再ビルドしてください。

### ファイルサイズが大きすぎる
圧縮パラメータは `scripts/build.sh` の `sips` 行で調整できます:
- `-Z 1600` → 横幅上限(デフォルト1600px、下げるとさらに軽量化)
- `formatOptions 82` → JPEG品質(デフォルト82、下げるほど軽量だが画質低下)
