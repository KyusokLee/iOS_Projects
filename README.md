## iOS Toy Projects
![imge](https://img.shields.io/badge/ProjectType-SingleProject-green) ![imge](https://img.shields.io/badge/Language-Swift-red) ![imge](https://img.shields.io/badge/Tools-Xcode-blue)

学んだことや知識を活かして、簡単なトイプロジェクトを行うリポジトリです。
<br />

## 🌱MoreGreen
### 🎥デモ動画
- 商品の賞味期限をカメラで撮影し、リストに保存する

![moregreenDemo1-resize](https://user-images.githubusercontent.com/89962765/227226327-d9b9803e-4a91-4f6b-ab98-c3753495aa67.gif)

### ✍️概要
- MoreGreenは、家にある商品（食品など）の賞味期限を簡単に管理するアプリである。



### 📚今後の予定
* 🔥Main(優先)
  * GCPのOCRテキスト認証から、Swift 内装のフレームワークであるVision APIを使って実装 -> 経済的コストの削減
  * 賞味期限でヒットできなかった漢字・数字が混ざった賞味期限の認証 -> TestCodeでテストしながら、開発する予定！
  * ユーザさんがより使いやすいと感じるようなUIの配置 (TabbarControllerのitemの順番とmiddle buttonのCustomizeの理由を考え直す)
  * 不要なリソース、または、コードの可読性と重複したコードを改善

* 🌱実装したいと思う点
  * バーコード認証によるレシートの読み込み -> 買い物後に直ちに、商品の登録ができれば、ユーザさんが感じる便利性が高くなると考えた

### 🧐コード実装時の記録
* OCRテキスト認証関連
  * GCP Vision APIからiOS内装フレームワークであるVision導入へ
    - Google Cloud PlatformのAPIは、Requestの回数をある基準を超えと、お金の費用が発生する。
    - この理由から、iOS内装フレームワークであるVisionを導入することで、コストを削減することができると考えた。
    - 加えて、API Requestを介さずにテキスト認証を行うので、アプリの全体のプロセスを１ステップ削減することもできる。
  * 使ってみた結果、年月日が混ざっている賞味期限の認証ができない
    - 正規表現のモデル構築を改善する。また、テストコードを作成しながら、確認する。
* テストコードの作成
  * テストコードを作成しながら、実装した結果、各モジュールを部分的に確認することができてどのモジュールで問題が発生するかを迅速に確認・対応するこができた
  * ネットワーク辺りのエラーもビルド以前に確認することができ、コード作成・変更が柔軟であることを感じた
  
* TabbarController関連
  * TabbarControllerのItem配置はどのようにするべきか？
    - このアプリを通して、ユーザが一番使って欲しいもの、使いやすくするためにはどのような配置にするかを工夫した
    - Home画面(1st item)では、7日以内の賞味期限を表示させ、ユーザが家の食品をより意識するように誘導する
    - Item List(2nd item)で、登録した食品リストが見れる
    - このアプリの主な機能である食品登録機能を真ん中の + ボタンとして配置し、ユーザが使用するときの注目を集めるように
  
  * TabBarControllerの真ん中にあるCustom Buttonについて
    - デザイン変更中

### Error Handling

  
  
