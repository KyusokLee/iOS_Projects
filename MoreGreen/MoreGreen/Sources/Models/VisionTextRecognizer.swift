//
//  VisionTextRecognizer.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/26.
//

import Foundation
import UIKit
import Vision

// GCP から Visionへ変更: API Requestのコスト削減, Networkプロセスを省くことが可能
struct VisionTextRecognizer: VisionTextRecognizerProtocol {
   // MARK: - Vision Frameworkでテキスト認証
    func recognize(ciImage: CIImage, completion: @escaping (([String], Error?) -> Void)) {
        // テキスト認証結果を格納するString型配列
        var texts: [String] = []
        var request = VNRecognizeTextRequest()
        
        request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("The observations you tried are of unexpected types.")
                completion([], error)
                return
            }
            // 最大のテキスト候補を5つまで
            let maximumCandidates = 5
            for observation in observations {
                guard let candidates = observation.topCandidates(maximumCandidates).first else {
                    continue
                }
                texts.append(candidates.string)
            }
            completion(texts, nil)
        }
        
        // MARK: - 日本語が正しく表示されなかったエラーはrecognitionLanguagesメソッドで日本語に設定するタイミングが原因
        // 調べたところ、テキスト認証 -> その後、テキストから日本語（以外の言語も）を検出する順番?のイメージ
        request.recognitionLanguages = ["ja-JP", "ko-KR", "en-US"]
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
    func recognize(ciImage: CIImage, completion: @escaping(([String], Error?) -> Void))
}
