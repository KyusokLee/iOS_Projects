//
//  NewItemViewPresenter.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/04/12.
//

import Foundation
import UIKit

// インタフェースの定義
protocol TextRecognizeResultView: AnyObject {
    func shouldShowTextRecognizeResult(with results: [String])
    func shouldShowRecognitionFailFeedback()
}

final class NewItemViewPresenter {
    private let textRecognizer: VisionTextRecognizerProtocol
    private weak var view: TextRecognizeResultView?
    
    init(textRecognizer: VisionTextRecognizerProtocol, view: TextRecognizeResultView) {
        self.textRecognizer = textRecognizer
        // イニシャライザでViewを受け取る
        self.view = view
    }
    
    // VisionはNetworkを介して行われるかどうかを試す
    // 試したところ、VisionはNetworkを介さずに行う ->理由: 内装のフレームワークであるため、Appleプラットフォームで完結
    func loadItemInfomation(from image: CIImage) {
        textRecognizer.recognize(ciImage: image, completion: { (results, error) in
            guard error == nil else {
                return
            }
            
            if results.isEmpty {
                self.view?.shouldShowRecognitionFailFeedback()
            } else {
                self.view?.shouldShowTextRecognizeResult(with: results)
            }
            
        })
    }
}
