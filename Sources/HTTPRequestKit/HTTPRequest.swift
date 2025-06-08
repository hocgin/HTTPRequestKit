import Combine
import Foundation

public struct HTTPRequest {
    public var baseURL: URL
    public var path: String
    public var method: Method
    public var headers: HTTPHeaders
    public var dataType: DataType
    let asURLRequest: () -> URLRequest

    // swiftlint:disable function_parameter_count
    static func getRequest(
        _ url: URL,
        headers: HTTPHeaders,
        dataType: DataType,
        method: Method
    ) -> URLRequest {
        let url = url.queryWith(items: dataType.queryItems, params: dataType.parameters)
        var request = URLRequest(url: url)
        request.setupRequest(headers: headers, method: .get)
        return request
    }

    static func putPatchPostRequest(
        _ url: URL,
        headers: HTTPHeaders,
        dataType: DataType,
        method: Method
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.setupRequest(headers: headers, method: method)
        request.httpBody = dataType.data
        return request
    }

    static func deleteRequest(
        _ url: URL,
        headers: HTTPHeaders,
        dataType: DataType,
        method: Method
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.allowsCellularAccess = true
        request.setupRequest(headers: headers, method: method)
        request.httpBody = dataType.data
        return request
    }

    public static func build(
        baseURL: URL,
        method: Method = .get,
        headers: HTTPHeaders = .default,
        path: String = "",
        dataType: DataType = .none,
        urlQueryItems: [URLQueryItem]? = nil
    ) -> Self {
        var url = baseURL
        url.appendPathComponent(path)

        return .init(
            baseURL: baseURL, path: path, method: method, headers: headers,
            dataType: dataType
        ) { () -> URLRequest in

            switch method {
            case .get:

                return getRequest(
                    url, headers: headers, dataType: dataType, method: .get
                )

            case .put, .patch, .post:

                return putPatchPostRequest(
                    url, headers: headers, dataType: dataType, method: method
                )

            case .delete:
                return deleteRequest(
                    url, headers: headers, dataType: dataType, method: method
                )
            }
        }
    }

    public static func build(
        baseURL: String,
        method: Method = .get,
        headers: HTTPHeaders = .default,
        path: String = "",
        dataType: DataType = .none,
        urlQueryItems: [URLQueryItem]? = nil
    ) -> Self {
        .build(
            baseURL: URL(string: baseURL)!,
            method: method,
            headers: headers,
            path: path,
            dataType: dataType,
            urlQueryItems: urlQueryItems
        )
    }

    public func send<D: Decodable, S: Scheduler>(
        urlSession: URLSession = URLSession.shared,
        jsonDecoder: JSONDecoder = .default,
        scheduler: S = DispatchQueue.main
    ) -> AnyPublisher<D, HTTPRequest.HRError> {
        return urlSession.dataTaskPublisher(for: asURLRequest())
            .assumeHTTP()
            .responseData()
            .decoding(D.self, decoder: jsonDecoder)
            .catch { (error: HTTPRequest.HRError) -> AnyPublisher<D, HTTPRequest.HRError> in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    public func publish<D: Decodable, S: Scheduler>(
        urlSession: URLSession = URLSession.shared,
        jsonDecoder: JSONDecoder = .default,
        scheduler: S = DispatchQueue.main
    ) -> AnyPublisher<D, HTTPRequest.HRError> {
        urlSession.dataTaskPublisher(for: asURLRequest())
            .assumeHTTP()
            .responseData()
            .decoding(D.self, decoder: jsonDecoder)
            .catch { (error: HTTPRequest.HRError) -> AnyPublisher<D, HTTPRequest.HRError> in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    public func sink<D: Decodable, S: Scheduler>(
        urlSession: URLSession = URLSession.shared,
        jsonDecoder: JSONDecoder = .default,
        scheduler: S = DispatchQueue.main,
        success: @escaping (D) -> Void,
        failure: @escaping (Error) -> Void = { _ in },
        completion: @escaping () -> Void = {}
    ) -> AnyCancellable {
        send(
            urlSession: urlSession,
            jsonDecoder: jsonDecoder,
            scheduler: scheduler
        ).sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure(let e): failure(e)
            }
            completion()
        }, receiveValue: success)
    }

    public func run<T>(_ type: T.Type = String.self, jsonDecoder: JSONDecoder = .default) async throws -> T where T: Decodable {
        let result = try await response()
        let data = try validate(data: result.0, response: result.1)
        if T.self == String.self {
            return String(data: data, encoding: .utf8) as! T
        }
        return try jsonDecoder.decode(T.self, from: data)
    }

    public func response() async throws -> (Data, URLResponse) {
        let request: URLRequest = asURLRequest()
        let result = try await URLSession.shared.data(for: request)
        return result
    }

    func validate(data: Data, response: URLResponse) throws -> Data {
        guard let _ = (response as? HTTPURLResponse)?.statusCode
        else {
            throw NSError(domain: String(data: data, encoding: .utf8) ?? "Network Error", code: 0)
        }
//        guard successRange.contains(code)
//        else
//        {
//            throw NSError(domain: "out of statusCode range", code: code)
//        }
        return data
    }
}

// Extension Start Here
public extension JSONDecoder {
    static let ISO8601JSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static let `default`: JSONDecoder = {
        let json = JSONDecoder()
        json.keyDecodingStrategy = .convertFromSnakeCase
        return json
    }()
}

extension HTTPRequest {
    var pathAppendedURL: URL {
        var url = baseURL
        url.appendPathComponent(path)
        return url
    }
}
