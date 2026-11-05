# Game Center と通知のセットアップ（iOS）

ゲーム側（`www/index.html`）の対応はもう入っています。iOS では以下の設定だけ行ってください。
Web 版（GitHub Pages）では Game Center と通知は自動で無効になり、今までどおり動きます。

## 1. パッケージを入れる

```bash
npm install            # package.json に @capacitor/local-notifications と @capacitor/haptics を追加済み
npx cap sync ios
```

## 2. Xcode の設定

`GameCenterPlugin.swift` と `MainViewController.swift` はXcodeプロジェクトに登録済みで、StoryboardとGame Center capabilityも設定済みです。
配布時は、Apple Developer/App Store Connect側でもGame Centerを有効にしてください。

## 3. App Store Connect で項目を作る

アプリの「Game Center」を有効にして、次の ID で作成してください（ID はコード内と完全一致させる必要があります）。

### リーダーボード（クラシック／整数／高いほど上位／ベストスコア）
| ID | 内容 |
|---|---|
| `cosmii.cannon.leaderboard.battle` | 最高クリアバトル |
| `cosmii.cannon.leaderboard.stars` | 獲得スターの合計 |

### 実績
| ID | 条件 |
|---|---|
| `cosmii.cannon.ach.clear10` | バトル10をクリア |
| `cosmii.cannon.ach.clear30` | バトル30をクリア |
| `cosmii.cannon.ach.clear50` | バトル50をクリア |
| `cosmii.cannon.ach.clear100` | バトル100をクリア |
| `cosmii.cannon.ach.clear200` | バトル200をクリア |
| `cosmii.cannon.ach.boss1` | ボスバトルを初クリア |
| `cosmii.cannon.ach.stars100` | スターを100個集める |
| `cosmii.cannon.ach.streak5` | 5連勝 |
| `cosmii.cannon.ach.streak10` | 10連勝 |
| `cosmii.cannon.ach.challenge7` | 今日のチャレンジを7回クリア |
| `cosmii.cannon.ach.claw1` | クレーンゲームで初ゲット |
| `cosmii.cannon.ach.plush10` | ぬいぐるみを10種集める |
| `cosmii.cannon.ach.plush20` | ぬいぐるみ20種コンプリート |

ID を変えたい場合は `www/index.html` の `GC_LEADERBOARDS` と `GC_ACHIEVEMENTS` を書き換えてください。

## 4. 動作

- ホーム表示時に Game Center へ自動サインイン（初回のみ Apple のシートが出ます）
- バトルクリアごとに、最高バトルと合計スターを送信し、条件を満たした実績を解除
- ランキング画面の右上に Game Center ボタン（リーダーボード）とトロフィーボタン（実績）が出ます（iOS アプリ内のみ）

## 5. 通知（ローカル通知）

- 2回目のバトルクリア後に「お知らせをONにする？」を一度だけ表示し、OK なら iOS の許可ダイアログを出します
- アプリを閉じたときに次を予約します：ハート満タン／翌日12:30 の無料ガチャ・チャレンジ／3日後 19:00 のおかえり通知
- 追加の Xcode 設定は不要です

## 6. 振動（Haptics）

- 設定の「振動」が ON のとき、発射・ボム・クリア時に端末が軽く振動します（`@capacitor/haptics`、追加設定は不要）

## 7. 未設定の URL

- サポート：`contact@airis-games.com` へのメール作成画面が開きます（`SUPPORT_URL`）
- 利用規約：公式サイトにページがないため `TERMS_URL` は空にしてあり、ボタンは非表示です。ページを作ったら URL を入れると表示されます
