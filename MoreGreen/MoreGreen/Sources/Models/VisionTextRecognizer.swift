//
//  VisionTextRecognizer.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/24.
//

import Foundation
import Vision

// GCP Vision APIから、Vision Frameworkを用いたテキスト認識に変える作業
struct VisionTextRecognizer: VisionTextRecognizerProtocol {
    func recognize(cgImage: CGImage, handler: @escaping([String]) -> Void) {
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
            handler(texts)
        }

        request.recognitionLanguages = ["ja-JP"]
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
    }
    
//    let request = VNRecognizeTextRequest { request, error in
//        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//
//        // OCR結果から認証させたいテキストを抽出
//        let recognizedStrings = observations.compactMap { observation in
//            return observation.topCandidates(1).first?.string
//        }
//        let detectedDates = recognizedStrings.compactMap { string in
//            return regex.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)).flatMap { match in
//                return (string as NSString).substring(with: match.range)
//            }
//        }
//        print(detectedDates)
//    }
//    request.recognitionLevel = .accurate
//
//    guard let cgImage = image.cgImage else { return }
//    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//
//    do {
//        try requestHandler.perform([request])
//    } catch {
//        print(error)
//    }
}

protocol VisionTextRecognizerProtocol {
    func recognize(cgImage: CGImage, handler: @escaping([String]) -> Void)
}

