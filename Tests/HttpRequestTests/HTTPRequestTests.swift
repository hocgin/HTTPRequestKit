@testable import HTTPRequestKit

import Combine
import Foundation
import Testing

struct TestResp: Codable {
    var message: String
}

@Test func testExample() async throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    // XCTAssertEqual(HttpRequest().text, "Hello, World!")

    let custom: HTTPHeaders = [
        .defaultAcceptEncoding,
        .defaultAcceptLanguage,
        .userAgent(HTTPHeader.makeUserAgent()),
    ]

    let request = HTTPRequest.build(
        baseURL: "https://9cb3e59a017449b081da7defd93dc684.api.mockbin.io/",
        headers: custom
    )

    let urlRequest = request.asURLRequest()
    debugPrint("isURLRequest \(urlRequest is URLRequest)")

    /// 方式 1
    let result1 = try await request.run(String.self)
    debugPrint("result1 = \(result1)")
    /// 方式 2
    let result2: (Data, URLResponse) = try await request.response()
    debugPrint("result2 0 = \(result2.0), 1 = \(result2.1)")
    /// 方式 3
    let result3 = try await request.run(TestResp.self)
    debugPrint("result3 = \(result3)")

    /// 方式 4
    let cancel = request.sink(success: { (result4: TestResp) in
        debugPrint("result4 = \(result4)")
    })
    /// 方式5
    let publish: AnyPublisher<TestResp, HTTPRequest.HRError> = request.publisher()
    let cancel5 = publish.sink(
        receiveCompletion: { debugPrint("receiveCompletion = \($0)") },
        receiveValue: { result5 in
            debugPrint("result5 = \(result5)")
        }
    )

    try? await Task.sleep(nanoseconds: 345678987654)
}

let jsonDecoder: JSONDecoder = {
    let json = JSONDecoder()
    json.keyDecodingStrategy = .convertFromSnakeCase
    return json
}()

@Test func example() async throws {
    let custom: HTTPHeaders = [
        .defaultAcceptEncoding,
        .defaultAcceptLanguage,
        .userAgent(HTTPHeader.makeUserAgent()),
    ]

    let request = HTTPRequest.build(
        baseURL: "https://9cb3e59a017449b081da7defd93dc684.api.mockbin.io/",
        headers: custom
    )

    let publisher = request.dataTaskPublisher()
        .decode(type: FlexibleString.self, decoder: jsonDecoder)
        .eraseToAnyPublisher()

    let cancel = publisher.sink(
        receiveCompletion: {
            print("[网络响应线程]：\(Thread.current), 主线程？\(Thread.isMainThread) receiveCompletion3 = \($0)")
        },
        receiveValue: { result in
            debugPrint("[网络响应线程]：\(Thread.current), 主线程？\(Thread.isMainThread) result3 = \(result)")
        }
    )

    let result = try await publisher.values.first(where: { _ in true })
}
