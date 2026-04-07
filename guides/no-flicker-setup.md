# Claude Code を快適に使う：No Flicker モードの設定

チャットアプリのように使える「No Flicker モード」を有効にする手順です。

---

## No Flicker モードとは？

- **Shift + Enter** で改行できる（Enterだけで送信）
- 画面のちらつきがなくスムーズに表示される
- チャットアプリっぽいUIで直感的に使いやすい

---

## 手順

### Step 1：今すぐ試してみる

まずはオプション付きで起動してみましょう：

```sh
CLAUDE_CODE_NO_FLICKER=1 claude
```

快適に使えたら、次のステップで永続化しましょう！

---

### Step 2：使っているシェルを確認する

ターミナルで以下を実行してください：

```sh
echo $SHELL
```

**結果の見方：**

| 表示 | シェルの種類 |
|------|------------|
| `/bin/zsh` | zsh（macOS Catalina以降のデフォルト） |
| `/bin/bash` | bash（古いMacや手動変更） |
| `/usr/local/bin/fish` など | fish など |

---

### Step 3：設定ファイルに追記して永続化する

シェルに合わせて、対応する設定ファイルを開きます。

#### zsh の場合

```sh
echo 'export CLAUDE_CODE_NO_FLICKER=1' >> ~/.zshrc
source ~/.zshrc
```

#### bash の場合

```sh
echo 'export CLAUDE_CODE_NO_FLICKER=1' >> ~/.bash_profile
source ~/.bash_profile
```

#### fish の場合

```sh
set -Ux CLAUDE_CODE_NO_FLICKER 1
```

---

### Step 4：確認する

以下のコマンドで設定が反映されているか確認：

```sh
echo $CLAUDE_CODE_NO_FLICKER
```

`1` と表示されれば成功です！

次回から `claude` だけで起動しても No Flicker モードになります。

---

## まとめ

```
echo $SHELL          # シェルを確認
↓
設定ファイルに export CLAUDE_CODE_NO_FLICKER=1 を追記
↓
source で設定を反映
↓
claude で起動 → 完了！
```
