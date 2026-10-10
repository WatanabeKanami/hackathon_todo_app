# todo_app

A new Flutter project.

## Chromeでのデバッグとタスクの保存

```sh
flutter run -d web-server --web-hostname localhost --web-port 8080
```

起動後、普段使うChromeで `http://localhost:8080` を開いてください。
毎回同じChromeプロファイルを使い、シークレットモードは使わないでください。
PowerShellでは `./run_web.ps1` でも起動できます。VS Codeでは実行構成
「Todo Web (保存用・通常のChromeで開く)」を選び、表示されたURLを通常のChromeで開きます。

`flutter run -d chrome` は一時プロファイルでChromeを起動し、終了時に
`.dart_tool/chrome-device` へデータをコピーします。終了方法やファイルロックなどで
引き継ぎに失敗することがあるため、保存確認には上記の起動方法を使ってください。
`web-server` はブラウザとのデバッグ連携が限定されるため、ブレークポイントなどの
デバッグが必要なときは `flutter run -d chrome` を使い分けてください。

`web_dev_config.yaml` でも開発用URLを `http://localhost:8080` に固定しています。
タスクは SharedPreferences を通してブラウザの localStorage に保存します。
ポート番号が変わると別の保存先になるため、再起動時も同じURLを使ってください。
この設定は Flutter 3.38 以降で有効です。古いFlutterでは
上記コマンドの明示的なホスト・ポート指定を使ってください。

以前の別ポートに保存したタスクは、このURLには自動で移行されません。
ブラウザのサイトデータ削除やアプリのアンインストールでも保存データは消えます。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## ひかりのTodo：画面とフィルター

ホームは時間帯に合わせた挨拶、今日が期日のタスクの達成状況、5カテゴリの選択シート、タスク一覧で構成しています。追加は右下の＋、編集・削除は各カードの「⋮」から行います。属性は任意で、追加・編集画面で選択済みのチップをもう一度押すと未設定に戻せます。

- カテゴリ内は各属性につき1条件、異なる属性間はANDで判定します。
- 気分・場所・時間帯・テーマ・難易度は保存したIDと一致するタスクを表示します。「どこでも」も一致判定です。
- 所要時間は保存された分数を使用し、5分以内は1～5分、15分以内は1～15分、30分以上は30分以上です。16～29分は所要時間条件を解除して表示できます。
- 時間帯と所要時間、難易度とごほうびは別条件で、組み合わせできます。
- 未設定の属性は、その属性で絞り込んだ場合だけ対象外です。旧データは未設定、ごほうびなしで安全に読み込みます。
- 選択シートのチップを再タップ、一覧の条件チップの×、リセットで解除できます。リセットは完了状態も「すべて」に戻します。初期表示は未完了です。
- 条件は追加・編集から戻っても維持します。アプリを再起動すると初期条件に戻ります。フィルターは保存されたタスクを変更しません。
- 今日の達成率はフィルターとは独立し、端末のローカル日付と期日の年月日で集計します。

保存サービスは継続しています。旧保存キー `todos` のデータは引き継ぎ、新しい保存キー `todo_state_v2` にタスクとスタンプを一緒に保存します。旧データは削除しません。通常のChromeで同じURL `http://localhost:8080` を使い、追加・属性設定・編集・完了・削除を試した後、ページを再読み込みして残ったタスクの復元を確認してください。

検証コマンド：`flutter analyze`、`flutter test`、`flutter build web --no-pub`。テストはフィルターの数値境界、旧データ互換、属性の保存復元、画面上での条件の組み合わせと解除、編集・削除、追加・完了、小画面を検証します。実ブラウザでの見た目と永続化は上記の起動方法で確認してください。


## ごほうびとスタンプ帳

「ごほうび付き」の未完了タスクを完了すると、特別なねぎらいを表示し、そのタスクの初回完了時に「がんばりました」スタンプを1個獲得します。スタンプはタスクIDにつき1個で、未完了に戻しても取り消さず、再完了で増えません。タスクを削除しても、達成時のタイトルと日時が記念として残ります。通常タスクや導入前から完了済みのタスクには自動付与しません。

ホーム左上のメニューから「がんばりましたスタンプ」を開くと、合計数と達成履歴をいつでも確認できます。スタンプはタスクと同様、この端末・ブラウザ内に保存されます。同じURLとChromeプロファイルで開くと再起動後も復元できます。
