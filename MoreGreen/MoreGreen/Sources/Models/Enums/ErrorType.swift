//
//  ErrorType.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/09.
//

import Foundation

enum ErrorType {
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
