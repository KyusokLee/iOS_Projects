//
//  PeriodElementsCreator.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/27.
//

import Foundation

// Itemの賞味期限を生成
// ⚠️今後、itemの商品名とbarcode認識結果、および、商品の種類(ラーメンかおかずか飲み物かかなど)とかも処理する予定
// 賞味期限は、日付しかないので、正規式を使わなくてもいい気がしてきた..

// 正規式のあだ名を設ける
typealias RegexPattern = String

// ほとんどの商品の賞味期限や有効期限が以下のような3つのパータンになっていることがわかった
// 22.12.21
// 2022.12.21 (たまに、　スペースが入って　2022. 12. 21のような表記もある)
// 2022-12-21
//

// 今後、商品の名前も対応させる予定
// 🌱まだ、知識が深くないから、自信はない
// ❓ちょっと複雑な正規式になったのかな?
enum TargetType: RegexPattern {
    // - 形式の日付
    // \\s: \sを正規式の文字として認識させるため
    // \s: 空白
    // \s?: 空白があってもなくても大丈夫
    // 2022-12-21, 22-12-21, 22-03-03, 22 - 03 - 03, (何らかの文字 2022 - 12 - 22), (何らかの文字 22 - 12 - 22)に対応させる正規式
    case endDateHyphen = "(\\s?(20[0-9]{2}|(2|3)[0-9])\\s?)\\-(\\s?([1-9]|0[1-9]|1[0-2])\\s?)\\-(\\s?([1-9]|0[1-9]|1[0-9]|2[0-9]|3[0-1]))"
    // . 形式の日付
    // 上記の例と同様に、　.を区切りにしたテキストを認識させる
    case endDateDot = "(\\s?(20[0-9]{2}|(2|3)[0-9])\\s?)\\.(\\s?([1-9]|0[1-9]|1[0-2])\\s?)\\.(\\s?([1-9]|0[1-9]|1[0-9]|2[0-9]|3[0-1]))"
}

struct ItemElementsCreator {
    // 賞味期限や消費期限の日付情報の生成
    func create(from recognizedString: String) -> EndDate {
        let texts = recognizedString.components(separatedBy: "\n")

        // TODO: ⚠️認識したい変数をここで定義
        var endDate: String?

        texts.forEach {
            // ハイフン形式の日付の認識
            let endDateHyphenRegex = try! NSRegularExpression(pattern: TargetType.endDateHyphen.rawValue)
            if let _ = endDateHyphenRegex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                endDate = $0
            }
            
            // . 形式の日付の認識
            let endDateDotRegex = try! NSRegularExpression(pattern: TargetType.endDateDot.rawValue)
            if let _ = endDateDotRegex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                endDate = $0
            }
        }
        
        // ここで、年、月、日を入れることも可能ではあるけど、logicとしてparsingをして、表示させるときに入れることにした
        
        // TODO: ⚠️返したい変数を構造体Modelとしてreturnする
        return EndDate(
            endDate: endDate
        )
    }
}
