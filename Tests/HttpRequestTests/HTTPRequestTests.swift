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
    let publish: AnyPublisher<TestResp, Error> = request.publisher()
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

@Test("测试 publisher 转 async")
func example2() async throws {
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

    let v = try await publisher.async()
    debugPrint("v = \(v)")
}

struct TestFmt: Codable {
    var isOk: Bool = false
    var status: Status
    var message: String
    var datetime: Date
    var precipitation2h: [Double]
    var precipitation: [Double]
    var serverTime: Int
    var direction: Decimal

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case datetime
        case precipitation2h = "precipitation_2h"
        case precipitation
        case serverTime = "server_time"
        case direction
    }

    enum Status: String, Codable {
        case success
        case failure
    }
}

@Test("测试时间格式化")
func example3() async throws {
    let jd: JSONDecoder = {
        let json = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mmXXX" // 支持 +08:00
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        json.dateDecodingStrategy = .formatted(formatter)
        return json
    }()

    let custom: HTTPHeaders = [
        .defaultAcceptEncoding,
        .defaultAcceptLanguage,
        .userAgent(HTTPHeader.makeUserAgent()),
    ]

    let request = HTTPRequest.build(
        baseURL: "https://8d0115cc766f493c8c06f41fc9fd661b.api.mockbin.io/",
        headers: custom
    )

    let result = try await request.run(TestFmt.self, jsonDecoder: jd)
    debugPrint("result = \(result)")
    debugPrint("result.Date = \(result.datetime.formatted())")
    debugPrint("result.Decimal = \(result.direction)")
    debugPrint("result.enum = \(result.status)")
}
