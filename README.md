# Promptalk

**AI を活用した英会話練習アプリ** 🎤💬

Promptalk は、様々なペルソナ（キャラクター）と自然な英会話練習ができる iOS アプリです。音声認識と AI を組み合わせて、いつでもどこでも英語のスピーキング練習ができます。

## ✨ 主な機能

- **🎭 多彩なペルソナ**: フレンドリーなネイティブスピーカー、ビジネスコーチ、旅行ガイドなど、シチュエーションに合わせたキャラクターと練習
- **🎙️ 音声入力**: マイクボタンを長押しして、自然に話しかけるだけで英語を入力
- **🔊 自動読み上げ**: AI の返答を自動で読み上げ。速度調整も可能
- **🌐 翻訳機能**: 分からない表現はタップで日本語訳を表示
- **📝 カスタムペルソナ**: 自分だけのオリジナルキャラクターを作成
- **📚 会話履歴**: 過去の会話を保存して、いつでも復習

## 📱 動作環境

- iOS 17.0 以降
- iPhone / iPad

## 🚀 インストール方法

### 開発者向け

```bash
# リポジトリをクローン
git clone https://github.com/akidon0000/Promptalk.git
cd Promptalk

# Xcode でプロジェクトを開く
open Promptalk.xcodeproj
```

### 必要なもの

- Xcode 15.0 以降
- OpenAI API キー（アプリ内の設定画面で入力）

## 📖 使い方

1. **API キーの設定**: 設定タブから OpenAI API キーを入力
2. **ペルソナを選択**: 会話タブから練習したいペルソナを選択
3. **会話を開始**: マイクボタンを長押しして話しかける、またはテキスト入力
4. **翻訳を確認**: 分からない表現は「翻訳」ボタンをタップ
5. **復習**: 履歴タブから過去の会話を確認

## 🏗️ アーキテクチャ

- **言語**: Swift
- **UI フレームワーク**: SwiftUI
- **データ永続化**: SwiftData
- **アーキテクチャ**: MVVM (ViewStore パターン)
- **非同期処理**: Swift Concurrency (async/await)

## 📂 ディレクトリ構成

```
Promptalk/
├── App/                # アプリのエントリーポイント
├── Features/           # 機能別モジュール
│   ├── Conversation/   # 会話画面
│   ├── History/        # 履歴画面
│   ├── Persona/        # ペルソナ選択・編集
│   └── Settings/       # 設定画面
├── Core/               # 共通コンポーネント
├── Data/               # データ層
│   ├── Models/         # データモデル
│   └── Services/       # API・音声サービス
└── Resources/          # アセット
```

## 🧪 テスト

```bash
# ユニットテストを実行
xcodebuild test -scheme Promptalk -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 🤝 コントリビューション

1. Fork してブランチを作成 (`git checkout -b feature/amazing-feature`)
2. 変更をコミット (`git commit -m 'feat: add amazing feature'`)
3. Push (`git push origin feature/amazing-feature`)
4. Pull Request を作成

### コミット規約

[Conventional Commits](https://www.conventionalcommits.org/) に従います:

- `feat:` 新機能
- `fix:` バグ修正
- `refactor:` リファクタリング
- `test:` テスト追加
- `docs:` ドキュメント更新

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。

## 👤 作者

**akidon0000**

- GitHub: [@akidon0000](https://github.com/akidon0000)

---

<div align="center">
Made with ❤️ for English learners
</div>
