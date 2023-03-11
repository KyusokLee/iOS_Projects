//
//  EndPeriodJSONParser.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/27.
//

import Foundation

// TEXT OCR結果から得られたJSONデータをparsingする
struct EndDateJSONParser: EndDateJSONParserProtocol {
    private let itemInfoCreater: ItemElementsCreator

    init(itemInfoCreater: ItemElementsCreator) {
        self.itemInfoCreater = itemInfoCreater
    }

    func parse(data: Data) -> EndDate? {
        let decoder = JSONDecoder()
        guard let imageResponse = try? decoder.decode(ImagesResponse.self, from: data),
        let recognizedString = imageResponse.responses.first?.textAnnotations?.first?.description else {
            return nil
        }
        
        return itemInfoCreater.create(from: recognizedString)
    }
}

protocol EndDateJSONParserProtocol {
    func parse(data: Data) -> EndDate?
}
