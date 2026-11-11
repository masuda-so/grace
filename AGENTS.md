# リポジトリガイドライン

## プロジェクト構成とモジュールの配置

Grace は 大切な出来事を文章や写真で記録する、プライベートな感謝日記アプリ（SwiftUI、SwiftData、StoreKit 2、Apple Foundation Models）。Xcode プロジェクト `grace.xcodeproj` にターゲットが 2 つある。

- `grace/App/` — エントリーポイント `GraceApp.swift`、ルート `Navigation/AppRootView.swift`、環境と商品定義（`General/`）、機能ごとの画面（Achievements / Assistant / General / Moments / Navigation / Paywall / Settings）。
- `grace/Services/` — 画面がプロトコル越しに使う実装（AI / Achievements / Commerce / Data / Photos）。`AIClient` と `SubscriptionClient` が契約で、本番実装とプレビュー・利用不可時の実装を差し替える。
- `grace/Components/`（複数の機能で使うビュー）、`grace/Models/`（ドメイン型と SwiftData モデル）、`grace/Resources/`（アセット、文字列カタログ、ローカルの StoreKit 設定）、`grace/Supporting Files/`（`PrivacyInfo.xcprivacy`）。
- `graceTests/Unit/`、`graceTests/Integration/`、`graceTests/Support/`（テストバンドルのリソース参照）。`docs/` に製品範囲、出どころ、プライバシー、リリースの文書。

## ビルド・テスト・開発コマンド

- `xcodebuild build-for-testing -scheme grace -project grace.xcodeproj -destination "platform=iOS Simulator,name=<iPhone>,OS=<iOS>"` — テストを含めてビルドする。通常 CI（`.github/workflows/ios.yml`）は最新の iOS ランタイムにある iPhone を `xcrun xctrace list devices` で選び、`name=` と `OS=` の両方を渡す。
- `xcodebuild test-without-building -scheme grace -project grace.xcodeproj -destination "<同じ>" -test-timeouts-enabled YES -skip-testing:graceTests/StoreKitIntegrationTests` — 通常 CI のテスト。StoreKit 統合テストは除外する。
- StoreKit 専用 CI（`.github/workflows/storekit-validation.yml`、`xcode-27` ランナー、Xcode 27.1）: 商品取得の事前確認 → 必須 8 件 → 観測のみのストリーム 1 件の順に `xcodebuild test -only-testing:graceTests/StoreKitIntegrationTests/<テスト名>` を実行する。必須 8 件だけが合否。
- `xcrun swift-format lint --strict --recursive grace graceTests` — 整形と文書コメントの検査。

## コーディングスタイルと命名規則

- 整形は `.swift-format`（2 スペース、1 行 100 桁、`NeverForceUnwrap` / `NeverUseForceTry` / `NeverUseImplicitlyUnwrappedOptionals`、公開宣言には文書コメント）。`!` と `try!` を持ち込まない。`.editorconfig` が文字コード・改行・インデントを揃える。
- Swift API Design Guidelines に従い、型は UpperCamelCase、メソッドとプロパティは lowerCamelCase。ファイル名は主要な型か責務に合わせる。機能固有のビューは機能のフォルダに置き、複数の機能で使うようになったら `Components/` に昇格させる。
- Xcode プロジェクトは synchronized folders。取り込んだ画像や生成物に整形を適用しない。

## テストの指針

- XCTest。`Unit/` はモデル・サービス・描画の焦点を絞ったテスト（`AIPlatformTests`、`CommercePlatformTests`、`GraceFoundationTests`、`StreakCalculatorTests`、`ViewRenderingTests`）、`Integration/` は `StoreKitIntegrationTests` と `LocalizationCatalogTests`。
- StoreKit 統合テストはローカルのテスト商品を使い、App Store Connect の準備状況は示さない。通常 CI では除外し、専用 CI の必須 8 件を合否にする。CI が緑でも全 9 件の成功や通知処理の解決を意味しない。
- テストは `Bundle` の参照だけを使い、開発機のソースパスを使わない。`-test-timeouts-enabled YES` は外さない。

## コミットとプルリクエストの指針

- コミットは git 公式ガイドの形: 1 行目は 50 文字以内を目安にした要約、空行、本文（何を・なぜ、72 桁前後で折り返す）、空行、トレーラー。作者は `masudaso <258961222+masuda-so@users.noreply.github.com>`、SSH 署名付き（ルールセットで署名必須）。
- 初回コミットだけ author と committer の日時をその日の `00:00:00 +0900` に揃える。2 回目以降は実際の日時。
- AI が内容を書いたコミットには、関わったエージェントごとに GitHub 公式書式のトレーラーを 1 行ずつ付ける: `Co-authored-by: Codex <noreply@openai.com>`、`Co-authored-by: Claude Fable 5.1 <noreply@anthropic.com>`（モデル名は作業したもの）。大文字小文字は公式どおり `Co-authored-by:`。
- 公開済みの履歴は書き換えない。やむを得ない場合は本人が判断し `--force-with-lease` を使う。
- 作業は GitHub flow に従う。1 作業ごとに main から、内容が分かる短い名前のブランチを切る（担当や種類を表す接頭辞は付けない）。
- PR は一つの目的に絞って小さく保ち、提出前に自己レビューと検査を済ませる。取り込みは squash だけ（main には 1 PR＝1 コミット。設定とルールセットで merge と rebase を不許可にしている）。マージ後はブランチを消す。
- main への変更は PR 経由（直接 push 不可）。PR の題名・説明・レビューコメントは日本語を基本とし、利用者が別の言語を指定した場合はそれを優先する。説明には変更内容と検証結果を書く。通常 CI（Build and Test） が必須チェック。
- `README.md`（日本語）と `README.en.md`（英語）は冒頭で相互リンクし、5 見出し（概要・主な機能と制約・導入と使い方・サポートと関連資料・開発と貢献）を揃え、仕様・手順・制約の変更は同じ PR で両方を更新する。未実装・未検証の内容を利用可能と書かない。

## セキュリティと設定の注意

- StoreKit 設定は製品のリソースに含めない。認証情報、API キー、App Store Connect の鍵をリポジトリに置かない。
- 取り込んだ Apple サンプルの URL・リビジョン・ライセンス・改変点は `docs/References.md` と `THIRD_PARTY_NOTICES.md` に記録する。サンプルを写したことは、アプリ全体・プライバシー宣言・リリースの適合を保証しない。
- iOS 18.0 以上、Swift 6.0（`SWIFT_APPROACHABLE_CONCURRENCY` 有効）。実機や本番ストアでの動作は別途検証する。

## エージェント向けの指示

- 作業報告、Issue や PR へのコメントは日本語を基本とする。コード識別子、ファイル名、コマンド、ログやエラーの引用は原文のまま残し、説明を日本語で添える。
- 言語の統一を理由に既存のコミット履歴や他者のコメントを書き換えない。投稿・コミット・push の許可は別途の作業指示に従う。
