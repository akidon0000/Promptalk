# Promptalk - 開発ガイドライン

## 実装時チェックリスト

### コード品質

- [ ] SwiftLintを実行してエラー・警告がないこと
  ```bash
  swiftlint lint
  ```

- [ ] ビルドが通ること
  ```bash
  xcodebuild -scheme Promptalk -destination 'platform=iOS Simulator,name=iPhone 16' -quiet build
  ```

- [ ] テストが通ること
  ```bash
  xcodebuild test -scheme Promptalk -destination 'platform=iOS Simulator,name=iPhone 16' -quiet
  ```

### コミット前

- [ ] 不要なデバッグコード（print文など）を削除
- [ ] TODO/FIXMEコメントを確認
- [ ] 機密情報がコードに含まれていないこと

---

## コーディング規約

### Swift スタイル

- `guard` で早期リターン
- `async/await` を優先（Combine より）
- オプショナルは適切にアンラップ（force unwrap 禁止）

### 命名規則

| 種類 | 規則 | 例 |
|------|------|-----|
| 型名 | UpperCamelCase | `UserProfileView` |
| 変数/関数 | lowerCamelCase | `fetchUserData()` |
| 定数 | lowerCamelCase | `maxRetryCount` |

### ファイル配置

```
Promptalk/
├── App/           # エントリーポイント
├── Features/      # 機能モジュール
│   └── [Feature]/
│       ├── Views/
│       ├── ViewModels/
│       └── Models/
├── Core/          # 共通コンポーネント
│   ├── Extensions/
│   ├── Utilities/
│   └── Components/
└── Resources/     # リソース
```

---

## Git ワークフロー

### ブランチ命名

- `feature/<機能名>` - 新機能
- `fix/<バグ名>` - バグ修正
- `refactor/<対象>` - リファクタリング

### コミットメッセージ

```
<type>(<scope>): <subject>

type: feat | fix | refactor | test | docs | chore
```

例:
```
feat(Home): ホーム画面のUI実装
fix(Auth): ログイン時のクラッシュを修正
test(API): ユーザー取得APIのテスト追加
```

---

## よく使うコマンド

```bash
# SwiftLint
swiftlint lint              # チェック
swiftlint lint --fix        # 自動修正

# Xcode
open Promptalk.xcodeproj    # プロジェクトを開く

# Git
git status
git add -A && git commit -m "message"
git push
```

---

## 注意事項

- 新しいファイルを追加したら `project.pbxproj` の更新を忘れずに
- UI変更時はLight/Darkモード両方で確認
- iOS 17.0以上をサポート
