//
//  MoreGreenTests.swift
//  MoreGreenTests
//
//  Created by Kyus'lee on 2023/03/20.
//

import XCTest
@testable import MoreGreen

// Test Codeを実装し、network・API辺りのテストを行う
// ここでは、実際使うAPIのtestを行う
// XCTFail -> 必ず失敗するエラーを生成
// XCTAssertTrue() -> 与えたパラメータの表現がTrueであることを表す
// XCTAssertFalse() -> 与えたパラメータの表現がfalseであることを表す
// XCTAssertNil() -> 与えたパラメータの表現がnilであることを指す
// XCTUnwrap -> 与えたパラメータの表現がnilでないことを表し、unwrapped valueを返す

final class GoogleVisionAPIPresenterTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func test品物の情報のロードをしなければ品物の情報のロードがされないこと() {
        let view = MockSuccessView()
        XCTAssertFalse(view.isCalledShouldShowResult)
        XCTAssertFalse(view.isCalledShouldShowNetworkErrorFeedback)
        XCTAssertFalse(view.isCalledShouldShowResultFailFeedback)
    }

    func testAPIとパースが成功した場合品物のロードが成功していること() {
        let view = MockSuccessView()
        let jsonParser = StubSuccessEndDateJSONParser()
        let apiClient = StubSuccessAPIClient()
        
        let presenter = ItemInfoViewPresenter(
            jsonParser: jsonParser,
            apiClient: apiClient,
            itemView: view
        )
        
        presenter.loadItemInfo(from: "")
        XCTAssertTrue(view.isCalledShouldShowResult)
        XCTAssertFalse(view.isCalledShouldShowNetworkErrorFeedback)
        XCTAssertFalse(view.isCalledShouldShowResultFailFeedback)
    }

    func testAPI通信が失敗した場合はネットワークエラーになること() {
        let view = MockSuccessView()
        let jsonParser = StubSuccessEndDateJSONParser()
        let apiClient = StubFailureAPIClient()
        
        let presenter = ItemInfoViewPresenter(
            jsonParser: jsonParser,
            apiClient: apiClient,
            itemView: view
        )

        presenter.loadItemInfo(from: "")
        XCTAssertFalse(view.isCalledShouldShowResult)
        XCTAssertTrue(view.isCalledShouldShowNetworkErrorFeedback)
        XCTAssertFalse(view.isCalledShouldShowResultFailFeedback)
    }

    func testAPI通信は成功したがJSONのパースに失敗した場合は認識エラーになること() {
        let view = MockSuccessView()
        let jsonParser = StubFailureEndDateJSONParser()
        let apiClient = StubSuccessAPIClient()
        
        let presenter = ItemInfoViewPresenter(
            jsonParser: jsonParser,
            apiClient: apiClient,
            itemView: view
        )
        
        presenter.loadItemInfo(from: "")
        XCTAssertFalse(view.isCalledShouldShowResult)
        XCTAssertFalse(view.isCalledShouldShowNetworkErrorFeedback)
        XCTAssertTrue(view.isCalledShouldShowResultFailFeedback)
    }
}

private extension GoogleVisionAPIPresenterTest {
    final class MockSuccessView: ItemInfoView {
        // 外部では読み込みだけを可能とさせたいから、private(set) varにした
        private(set) var isCalledShouldShowResult = false
        private(set) var isCalledShouldShowAPIErrorFeedback = false
        private(set) var isCalledShouldShowNetworkErrorFeedback = false
        private(set) var isCalledShouldShowResultFailFeedback = false
        
        func shouldShowSuccessToShowItemInfo(with endDate: MoreGreen.EndDate) {
            isCalledShouldShowResult = true
        }
        
        func shouldShowNetworkErrorFeedback(error errorType: MoreGreen.ErrorType) {
            isCalledShouldShowNetworkErrorFeedback = true
        }
        
        func shouldShowFailToRecognizeFeedback(error errorType: MoreGreen.ErrorType) {
            isCalledShouldShowResultFailFeedback = true
        }
    }
    
    final class StubSuccessEndDateJSONParser: EndDateJSONParserProtocol {
        func parse(data: Data) -> EndDate? {
            return EndDate(
                endDate: "2023-3-21"
            )
        }
    }
    
    final class StubFailureEndDateJSONParser: EndDateJSONParserProtocol {
        // 検索にHitするものがなくても、totalCountは0を returnする
        // よって、nilであれば、RepositoryのParsingに失敗したということを想定する
        func parse(data: Data) -> EndDate? {
            return nil
        }
    }
    
    final class StubSuccessAPIClient: GoogleVisionAPIClientProtocol {
        func send(base64String: String, completion: @escaping ((Data?, Error?) -> Void)) {
            // 空のData Bufferを１つ生成.また、successの場合を想定したため、errorはnilにした
            completion(Data(capacity: 1), nil)
        }
    }
    
    // Network Errorは、HTTPURLResponseではないから、HTTPURLResponse()はそのまま返すようにした
    final class StubFailureAPIClient: GoogleVisionAPIClientProtocol {
        func send(base64String: String, completion: @escaping ((Data?, Error?) -> Void)) {
            completion(nil, ErrorType.networkError)
        }
    }
    
    // Client側とServer側に分けるテストコード
}
