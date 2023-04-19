//
//  VisionTextRecognizer.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/26.
//

import Foundation
import UIKit
import Vision

// TODO: RecognizerでItemElementsCreatorを受け取るようにする
// GCP から Visionへ変更: API Requestのコスト削減, Networkプロセスを省くことが可能
struct VisionTextRecognizer: VisionTextRecognizerProtocol {
    // 認証させたいテキストのRegexTypeを生成するmodel
    // itemInfoCreator -> ExpirationDateのModelを返している
    private let itemInfoCreator: ItemElementsCreator
    
    init(itemInfoCreator: ItemElementsCreator) {
        self.itemInfoCreator = itemInfoCreator
    }
    
    // MARK: - Vision Frameworkでテキスト認証
    // ParameterをStringにした理由:　Targetとするテキストは'賞味期限' と '商品名'である
    // まずは、それぞれのTextの認証ができるかを実装した後、 -> 一回のカメラ撮影処理で商品名と賞味期限を全部認証させるようにする
    func recognize(ciImage: CIImage, completion: @escaping ((String, Error?) -> Void)) {
        // テキスト認証結果を格納するString型配列
        var text = ""
        var request = VNRecognizeTextRequest()
        
        request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("The observations you tried are of unexpected types.")
                completion("", error)
                return
            }
            // 最大のテキスト候補を5つまで
            let maximumCandidates = 1
            for observation in observations {
                guard let candidates = observation.topCandidates(maximumCandidates).first, candidates.con else {
                    continue
                }
                // candidatesが
                
                
//
                // 正規表現のmatchをする
//                if let match = text.range(of: self.expirationDatePattern, options: .regularExpression) {
//                    let expirationDate = text.substring(with: match)
//                    print("商品の賞味期限は \(expirationDate) です。")
//                }
                text.append(candidates)
            }
            completion(text, nil)
        }
        
        // MARK: - 日本語が正しく表示されなかったエラーはrecognitionLanguagesメソッドで日本語に設定するタイミングが原因
        // 調べたところ、テキスト認証 -> その後、テキストから日本語（以外の言語も）を検出する順番?のイメージ
        request.recognitionLanguages = ["ja-JP", "en-US"]
        let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        // ここで、imageの処理を進める感じ
        // 画像に対しての解析リクエストを処理するためのオブジェクト
        DispatchQueue.main.async {
            do {
                try requestHandler.perform([request])
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

protocol VisionTextRecognizerProtocol {
    func recognize(ciImage: CIImage, completion: @escaping((String, Error?) -> Void))
}
