//
//  ItemViewPresenter.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import Foundation

// ModelとView（View Controller）間の架け橋の役をするPresenter
protocol ItemInfoView: AnyObject {
    func successToShowItemInfo(with endDate: EndDate)
    func networkError()
    func failToRecognize()
}

// initializerでDIを行い、Testを容易にする
// MARK: ModelとView間のdata fetchを担当するpresenter
final class ItemInfoViewPresenter {
    private let jsonParser: EndDateJSONParserProtocol
    private let apiClient: GoogleVisonAPIClientProtocol
    private weak var itemView: ItemInfoView?
    
    // initだけ打ったら自動で完成さらたんだが、、‼️
    init(
        jsonParser: EndDateJSONParserProtocol,
        apiClient: GoogleVisonAPIClientProtocol,
        itemView: ItemInfoView
    ) {
        self.jsonParser = jsonParser
        self.apiClient = apiClient
        // initializerでviewを受け取る
        self.itemView = itemView
    }
    
    // Google APIとのネットワーク処理を行い、処理後のイベントを管理するメソッド
    func loadItemInfo(from base64String: String) {
        apiClient.send(base64String: base64String) { (data, error) in
            guard error == nil, let hasData = data else {
                self.itemView?.networkError()
                return
            }
            
            if let endDate = self.jsonParser.parse(data: hasData) {
                self.itemView?.successToShowItemInfo(with: endDate)
            } else {
                self.itemView?.failToRecognize()
            }
        }
    }
}
