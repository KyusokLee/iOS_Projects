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
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil
            else {
                print("The observations you tried are of unexpected types.")
                completion("", error)
                return
            }
            // 最大のテキスト候補を1つまで
            let maximumCandidates = 1
            for observation in observations {
                // VNConfidence: 観測物の精度の信頼水準を指す -> 0 ~ 1.0
                guard let candidates = observation.topCandidates(maximumCandidates).first,
                      candidates.confidence > 0.1
                else {
                    continue
                }
                // candidatesがカメラが追跡したテキストオブジェクトのことを言う
                // つまり、このcandidatesと認証させたいテキスト(賞味期限)が一致するかを確認する処理が必要
                let textString = candidates.string
                let expirationDateModel = itemInfoCreator.create(from: textString)
                
                // TODO: - ExpirationModel (商品名、賞味期限)を返すように変更するつもり
                if let expirationDate = expirationDateModel.expirationEndDate {
                    text = expirationDate
                }
            }
            completion(text, nil)
        }
        
        // MARK: - 日本語が正しく表示されなかったエラーはrecognitionLanguagesメソッドで日本語に設定するタイミングが原因
        // 調べたところ、テキスト認証 -> その後、テキストから日本語（以外の言語も）を検出する順番?のイメージ
        // RequestのVision バージョンの設定
        // Revision3が一番最近のもの
        request.revision = VNRecognizeTextRequestRevision3
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ja-JP", "en-US", "ko-KR"]
        request.usesLanguageCorrection = true
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
