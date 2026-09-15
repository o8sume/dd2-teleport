[English](README.md) | **日本語**

# Dragon's Dogma 2 - Teleport Mod

REFrameworkを使用した、Dragon's Dogma 2向けの軽量なテレポートModです。

## 機能

- あらかじめ登録された地点へのテレポート
- カスタム地点の保存・利用
- 探求心の証（Seeker's Token）の地点へのテレポート
- 金色のテイオウコガネ（Golden Trove Beetle）の地点へのテレポート
- テレポート用ホットキーのカスタマイズ
- 登録地点へ素早くテレポートできるTeleport Window

## 必要環境

- Dragon's Dogma 2
- REFramework
- _ScriptCore

## インストール

以下のファイルとフォルダをREFrameworkの `autorun` ディレクトリにコピーしてください。

- `teleport.lua`
- `data/`

配置後のディレクトリ構成は以下のようになります。

```text
reframework/
└── autorun/
    ├── teleport.lua
    └── data/
```

## 使い方

REFrameworkのUIを開き、**Teleport** セクションを展開するとModを使用できます。

**Locations** から移動先を選択し、**Teleport** ボタンを押すとその地点へテレポートします。

Teleport Windowを使用して、登録済みの地点へ素早くテレポートすることもできます。

デフォルトでは `T` キーでTeleport Windowの表示・非表示を切り替え、`F1` ～ `F12` キーでウィンドウに表示されている対応地点へテレポートできます。

ホットキーは_ScriptCoreのホットキー設定から変更できます。

## カスタム地点

**Name** フィールドに名前を入力し、**Add Custom Location** を押すと現在地を保存できます。

保存したカスタム地点は **Locations** の一覧に追加され、あらかじめ登録されている地点と同じように利用できます。

保存したカスタム地点は **Delete Custom Locations** から削除できます。

## 追加地点

**Extra Locations** では、収集アイテム用の追加テレポート地点を利用できます。

- 探求心の証（Seeker's Token）の地点
- 金色のテイオウコガネ（Golden Trove Beetle）の地点

これらの地点は **Options** から有効・無効を切り替えられます。

## オプション

- **Load Seeker Stone Locations** — 探求心の証の地点を表示・非表示にします。
- **Load Golden Beetle Locations** — 金色のテイオウコガネの地点を表示・非表示にします。

これらの設定は現在のゲームセッションにのみ適用され、ゲームを再起動するとリセットされます。

## 互換性

以下の環境で開発・動作確認しています。

- Dragon's Dogma 2 TU3.2
- REFramework Nightly 01414
- TDB Version 83
- ScriptCore 1.2.07

その他のバージョンでの動作は保証されません。ゲームまたはREFrameworkのアップデートによって、このModのアップデートが必要になる場合があります。

## ライセンス

このプロジェクトはMIT Licenseのもとで公開されています。詳細は [LICENSE](LICENSE) を参照してください。