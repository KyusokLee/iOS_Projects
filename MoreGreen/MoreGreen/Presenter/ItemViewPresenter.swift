//
//  ItemViewPresenter.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import Foundation

// ModelとView（View Controller）間の架け橋の役をするPresenter

protocol ItemInfoView: AnyObject {
    func successToShowItemInfo(with ImageView: EndDate)
    func networkError()
    func failToRecognize()
}

// initializer必修
final class ItemInfoViewPresenter {
    private let jsonParser: EndDateJSONParserProtocol
    private let apiClient: GoogleVisonAPIClientProtocol
    private weak var itemView: ItemInfoView?
    
    // initだけ打ったら自動で完成さらたんだが、、‼️
    init(jsonParser: EndDateJSONParserProtocol, apiClient: GoogleVisonAPIClientProtocol, itemView: ItemInfoView? = nil) {
        self.jsonParser = jsonParser
        self.apiClient = apiClient
        // initializerでviewを受け取る
        self.itemView = itemView
    }
    
    
    func loadItemInfo(from base64String: String) {
        
    }
    
    
    
}
