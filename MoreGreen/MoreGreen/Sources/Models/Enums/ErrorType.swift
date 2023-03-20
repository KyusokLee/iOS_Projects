//
//  ErrorType.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/09.
//

import Foundation

// Error Typeを継承するEnumを生成 -> test codeの作成を容易にするため
enum ErrorType: Error {
    case networkError
    case parseError
}

extension ErrorType {
    var alertTitle: String {
        switch self {
        case .networkError:
            return "ネットワークエラー"
        case .parseError:
            return "パースエラー"
        }
    }
    
    var alertMessage: String {
        switch self {
        case .networkError:
            return "ネットワークに繋がっていません。\nもう一度、確認してください。"
        case .parseError:
            return "データを正しく表示できませんでした。\nもう一度、お試しください。"
        }
    }
}
