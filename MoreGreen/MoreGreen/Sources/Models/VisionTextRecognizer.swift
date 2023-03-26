//
//  VisionTextRecognizer.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/26.
//

import Foundation
import Vision

// Vision FrameWorkを用いたOCRテキスト認証
// GCP から Visionへ変更: API Requestのコスト削減, Networkプロセスを省くことが可能
struct VisionTextRecognizer: VisionTextRecognizerProtocol {
    func recognize(cgImage: CGImage, completion: @escaping([String]) -> Void) {
        var texts: [String] = []
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            for observation in observations {
                let candidates = observation.topCandidates(5)
                for candidate in candidates {
                    print(candidate.string)
                }
                texts.append(candidates.first!.string)
            }
            completion(texts)
        }

        request.recognitionLanguages = ["ja-JP"]
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
    }
}

protocol VisionTextRecognizerProtocol {
    func send(base64String: String, completion: @escaping ((Data?, Error?) -> Void))
    func recognize(cgImage: CGImage, completion: @escaping([String]) -> Void)
}
