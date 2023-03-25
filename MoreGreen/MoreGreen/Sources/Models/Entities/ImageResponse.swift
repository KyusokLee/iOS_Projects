//
//  ImageResponse.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/27.
//

import Foundation
// GCP OCRテキスト認証のとき、Imageに対する反応 Model
struct ImagesResponse: Codable {
    var responses: [AnnotateImageResponse]
}

struct AnnotateImageResponse: Codable {
    var textAnnotations: [EntityAnnotation]?
    var fullTextAnnotation: TextAnnotation?
}

struct EntityAnnotation: Codable {
    var mid: String?
    var locale: String?
    var description: String?
    var score: Float?
}

struct TextAnnotation: Codable {
    var text: String?
}
