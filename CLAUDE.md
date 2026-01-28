# Promptalk - iOS App

## プロジェクト概要

Promptalk は iOS アプリケーションです。

## 技術スタック

- **言語**: Swift
- **最小iOS**: iOS 17.0
- **アーキテクチャ**: MVVM or Clean Architecture
- **UI**: SwiftUI
- **非同期処理**: Swift Concurrency (async/await)

## 開発環境セットアップ

```bash
# 1. Xcodeを開く
open Promptalk.xcodeproj

# または SwiftPM の場合
open Package.swift
```

## ディレクトリ構成（推奨）

```
Promptalk/
├── App/                    # アプリのエントリーポイント
│   ├── PromptalkApp.swift
│   └── AppDelegate.swift
├── Features/               # 機能ごとのモジュール
│   └── [Feature]/
│       ├── Views/
│       ├── ViewModels/
│       └── Models/
├── Core/                   # 共通コンポーネント
│   ├── Extensions/
│   ├── Utilities/
│   └── Components/
├── Data/                   # データ層
│   ├── Repositories/
│   └── DataSources/
└── Resources/              # リソースファイル
    ├── Assets.xcassets
    └── Localizable.strings
```

## コマンド

### Claude Code スラッシュコマンド

- `/commit` - コミットを作成
- `/pr` - Pull Requestを作成

## コーディング規約

### Swift スタイル

- SwiftLint のルールに従う
- `guard` を積極的に使用して早期リターン
- オプショナルは適切にアンラップ
- `async/await` を優先（Combine より）

### 命名規則

- **型名**: UpperCamelCase (`UserProfileView`)
- **変数/関数**: lowerCamelCase (`fetchUserData`)
- **定数**: lowerCamelCase (`maxRetryCount`)

### コメント

- 公開APIには必ずドキュメントコメント
- 自明なコードにはコメント不要
- WHYを説明するコメントを優先

## テスト

```bash
# ユニットテスト実行
xcodebuild test -scheme Promptalk -destination 'platform=iOS Simulator,name=iPhone 15'
```

### テスト規約

- Swift Testing (`@Test`, `#expect`) を使用
- Arrange-Act-Assert パターン
- モックは Protocol を使用して依存性注入

## Git ワークフロー

### ブランチ戦略

- `main`: 本番リリース
- `feature/*`: 新機能
- `fix/*`: バグ修正

### コミットメッセージ

```
<type>(<scope>): <subject>

type: feat | fix | refactor | test | docs | chore
```

## CI/CD

- **GitHub Actions**: テスト自動実行、SwiftLint チェック
