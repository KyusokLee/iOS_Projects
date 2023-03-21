//
//  Bundle+Utils.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/20.
//

import Foundation
import OSLog

// GitHubにコミットするとき、GoogleVisionAPI Keyをplistで隠す方法
// gitignoreで隠し、Bundle.main.apiKeyのように呼び出す
extension Bundle {
    // OSLogでlogを出力するため
    var apiKey: String? {
        guard let file = self.path(forResource: "Secrets", ofType: "plist"),
              let resource = NSDictionary(contentsOfFile: file),
              let key = resource["API_KEY"] as? String else {
            os_log(.error, log: .default, "⛔️ API KEYの読み込みに失敗しました")
            return nil
        }
        return key
    }
}
