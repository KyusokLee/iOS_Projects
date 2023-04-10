//
//  PeriodElementsCreator.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/27.
//

import Foundation

// Itemの賞味期限を生成
// 今後、itemの商品名とbarcode認識結果、および、商品の種類(ラーメンかおかずか飲み物かかなど)とかも処理する予定
// ほとんどの商品の賞味期限や有効期限が以下のような3つのパータンになっていることがわかった
// 22.12.21
// 2022.12.21 (たまに、　スペースが入って　2022. 12. 21のような表記もある)
// 2022-12-21

// 日本語と混ざっている数字を認識できない -->修正中
// 正規式のあだ名を設ける
// MARK: - テキスト認識させるものを生成するCreator
typealias RegexPattern = String

enum TargetType: RegexPattern {
    // - 形式の日付
    // \\s: \sを正規式の文字として認識させるため
    // \s: 空白
    // \s?: 空白があってもなくても大丈夫
    // 2022-12-21, 22-12-21, 22-03-03, 22 - 03 - 03, (何らかの文字 2022 - 12 - 22), (何らかの文字 22 - 12 - 22)に対応させる正規式
    // - 形式の日付
    case expirationDateHyphen = "(\\s?(20[0-9]{2}|((2|3)[0-9]){0,1})\\s?)\\-(\\s?([1-9]|0[1-9]|1[0-2])\\s?)\\-(\\s?([0-9]{1,2}|0[1-9]|1[0-9]|2[0-9]|3[0-1]))"
    // . 形式の日付
    case expirationDateDot = "(\\s?(20[0-9]{2}|((2|3)[0-9])){0,2}\\s?)\\.(\\s?([1-9]|0[1-9]|1[0-2])\\s?)\\.(\\s?([0-9]{1,2}|0[1-9]|1[0-9]|2[0-9]|3[0-1]))"
    // /で区切られている日付の認識
    case expirationDateSlash = "(\\s?(20[0-9]{2}|((2|3)[0-9])){0,2}\\s?)\\/(\\s?([1-9]|0[1-9]|1[0-2])\\s?)\\/(\\s?([0-9]{1,2}|0[1-9]|1[0-9]|2[0-9]|3[0-1]))"
    
    // 日付の長さを正しく認識させるための正規式
    case expirationDateLength = "\\s?(\\d{2,4}-\\d{1,2}-\\d{1,2})"
    
    //TODO: - 数字と日本語が混ざっているものを認識させたい
    // 途中の段階 -> 漢字を読み取ると、hyphenや.などの認証がおかしくなっている
    // 例えば、2022年 10月 17日のような文字を認識させたいと思っている
    case expirationDateJapanese = "(\\s?(20[0-9]{2}|((2|3)[0-9])){0,2}\\s?)\\p{Han}{0,1}(\\s?([1-9]|0[1-9]|1[0-2])\\s?)\\p{Han}{0,1}(\\s?([0-9]{1,2}|0[1-9]|1[0-9]|2[0-9]|3[0-1])\\s?)\\p{Han}{0,1}"
    
//    case testKanji = "^\\p{Han}{1,3}\\s?\\p{Han}{1,3}$"
}

struct ItemElementsCreator {
    // 賞味期限や消費期限の日付情報の生成
    func create(from recognizedString: String) -> ExpirationDate {
        let texts = recognizedString.components(separatedBy: "\n")
        
        // TODO: 認識したい変数をここで定義
        var expirationDate: String?

        texts.forEach {
            // ハイフン形式の日付の認識
            let expirationDateHyphenRegex = try! NSRegularExpression(pattern: TargetType.expirationDateHyphen.rawValue)
            if let result = expirationDateHyphenRegex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                print($0)
                expirationDate = ($0 as NSString).substring(with: result.range(at: 0))
            }
            
            // . 形式の日付の認識
            let expirationDateDotRegex = try! NSRegularExpression(pattern: TargetType.expirationDateDot.rawValue)
            if let result = expirationDateDotRegex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                print($0)
                expirationDate = ($0 as NSString).substring(with: result.range(at: 0))
            }
            
            let expirationDateSlashRegex = try! NSRegularExpression(pattern: TargetType.expirationDateSlash.rawValue)
            if let result = expirationDateSlashRegex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) {
                print($0)
                expirationDate = ($0 as NSString).substring(with: result.range(at: 0))
            }
        }
        
        // ここで、年、月、日を入れることも可能ではあるけど、logicとしてparsingをして、表示させるときに入れることにした
        // TODO: ⚠️返したい変数を構造体Modelとしてreturnする
        return ExpirationDate(
            expirationDate: expirationDate
        )
    }
}
