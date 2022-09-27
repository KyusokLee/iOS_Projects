//
//  GoogleVisionAPIClient.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/27.
//

import Foundation

struct GoogleVisonAPIClient: GoogleVisonAPIClientProtocol {
    // API仕様はこちらを参照
    // https://cloud.google.com/vision/docs/ocr?hl=ja
    // https://cloud.google.com/vision/docs/reference/rest/v1/images/annotate?hl=ja#AnnotateImageRequest
    func send(base64String: String, completion: @escaping ((Data?, Error?) -> Void)) {
        // ここでCloud Vision APIのリクエストを組み立て
        // URLSessionを使って通信をする
        // 通信が終わったらcompletionを呼ぶ
        let request = buildRequest(with: base64String)
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }.resume()
    }
}

private extension GoogleVisonAPIClient {
    func buildRequest(with base64String: String) -> URLRequest {
        // ここにAPI keyが入る
        let apiKey = ""
        let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let params: [String: AnyObject] = [
            "requests": [
                "image": [
                    "content": "\(base64String)"
                ],
                "features": [[
                    "type": "TEXT_DETECTION",
                    "maxResults": 10,
                ]]
            ] as AnyObject
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        return request
    }
}

protocol GoogleVisonAPIClientProtocol {
    func send(base64String: String, completion: @escaping ((Data?, Error?) -> Void))
}
