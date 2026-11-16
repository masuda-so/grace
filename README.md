# Grace

[日本語](README.md) | [English](README.en.md)

## 概要

Graceは、大切な出来事を文章や写真で記録する、プライベートな感謝日記アプリです。

## 主な機能と制約

### 主な画面

- Moments
- Achievements
- Assistant
- Pro
- Settings

### 主な機能

記録はSwiftDataで端末内に保存します。タイトルは必須で、任意の文章・写真と作成日時を持ちます。作成、六角形のタイムライン表示、詳細表示、確認付き削除に対応しています。

日記の操作はAppleの「Views and data storage」チュートリアルを参考にしつつ、Graceのローカル構成、Foundation Modelsのアシスタント、StoreKit 2のアクセス管理を維持しています。

### アシスタントと購入

アシスタントには有効なProの利用権が必要です。対応する端末と言語でApple Foundation Modelsを使用します。

ローカルのStoreKit設定には、次の商品を定義しています。

- `llc.ether.grace.pro.daily`：自動更新しない24時間のDaily Pass。
- `llc.ether.grace.pro.monthly`：自動更新の月額プラン。
- `llc.ether.grace.pro.yearly`：自動更新の年額プラン。

App Store Connectの商品登録、本番価格、審査用情報の準備は、別途必要なリリース作業です。

## 導入と使い方

Xcodeで`grace.xcodeproj`を開き、共有スキーム`grace`を選択します。
ビルドとテストの手順は[構成と検証](docs/Structure.md)、端末要件とリリース条件は[リリース条件](docs/Release.md)を参照してください。
ローカルStoreKit設定は購入テスト用で、本番販売が可能であることの証明ではありません。

## サポートと関連資料

- [リポジトリ構成と検証](docs/Structure.md)
- [製品の範囲](docs/Product.md)
- [プライバシーポリシー](docs/Privacy.md)
- [利用規約](docs/Terms.md)
- [実装の参照元](docs/References.md)
- [リリース条件](docs/Release.md)
- [App Store提出記録](docs/App-Store-Submission.md)
- [第三者の権利表記](THIRD_PARTY_NOTICES.md)

公開サイトのパス：

- `https://ether-llc.com/apps/grace/privacy/`
- `https://ether-llc.com/apps/grace/terms/`
- `https://ether-llc.com/apps/grace/support/`

署名、検証、アップロード、公開、リリースには、リポジトリ外での作業も必要です。

## 開発と貢献

GitHub Actionsでは通常CIに加え、StoreKit専用CIで商品取得と購入関連8件を合格条件として検証します。未完了取引のストリーム1件は同じ取引IDの実finish完了を確認する厳格な判定のまま単独実行し、合否には含めず結果と成果物を記録します。storekitdの同期遅延とキャッシュ更新の揺れを観測していますが、根本原因は未確定です。CIが緑でも全9件の成功や通知処理の解決を意味しません。[追跡事項と検証範囲](docs/Structure.md#unresolved-stream-validation)を参照してください。実機や本番ストアでの動作は別途検証が必要です。

製品の問い合わせ先は上記のサポートURLです。リポジトリを変更する場合は、上記の実装の参照元とリリース条件を確認し、変更内容と検証結果をPRに記載してください。PRの説明とレビューコメントは日本語を基本とします。利用者が別の言語を指定した場合は、その指定を優先します。

作業時の共通方針は[AGENTS.md](AGENTS.md)を参照してください。

撮影用のDebug起動では、`--store-capture`を指定すると通常の保存領域を開かず、
メモリ内の架空の記録3件を使います。`--capture-empty`を併用すると空状態になります。
日英は起動言語に従います。このモードはReleaseビルドには含まれません。
実機で検証する場合は、既存のGraceを上書きしない別Bundle IDの開発用ビルドを使います。
撮影と操作検証の完了は、実行結果を別途確認してください。
