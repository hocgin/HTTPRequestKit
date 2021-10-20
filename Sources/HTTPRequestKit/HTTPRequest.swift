import Foundation
import Combine

public struct HTTPRequest {
  public var baseURL: URL
  public var path: String
  public var method: Method
  public var headers: [String: String]?
  public var authType: AuthType
  public var contentType: ContentType
  public var dataType: DataType
  let urlRequest: () -> URLRequest

  // swiftlint:disable function_parameter_count
  static func getRequest(
    _ url: URL, headers: [String: String]?, dataType: DataType,
    authType: AuthType, contentType: ContentType, method: Method
  ) -> URLRequest {

    let url = url.queryWith(items: dataType.queryItems, params: dataType.parameters)
    var request = URLRequest(url: url)
    request.setupRequest(headers: headers, authType: authType, contentType: contentType, method: .get)
    return request
  }

  static func putPatchPostRequest(
    _ url: URL, headers: [String: String]?, dataType: DataType,
    authType: AuthType, contentType: ContentType, method: Method
  ) -> URLRequest {

    var request = URLRequest(url: url)
    request.setupRequest(headers: headers, authType: authType, contentType: contentType, method: method)
    request.httpBody = dataType.data
    return request

  }

  static func deleteRequest(
    _ url: URL, headers: [String: String]?, dataType: DataType,
    authType: AuthType, contentType: ContentType, method: Method
  ) -> URLRequest {

      var request = URLRequest(url: url)
      request.allowsCellularAccess = true
      request.setupRequest(headers: headers, authType: authType, contentType: contentType, method: method)
      request.httpBody = dataType.data
      return request

  }

  public static func build(
    baseURL: URL, method: Method, headers: [String: String]? = nil,
    authType: AuthType, path: String, contentType: ContentType,
    dataType: DataType, urlQueryItems: [URLQueryItem]? = nil
  ) -> Self {

    var url = baseURL
    url.appendPathComponent(path)

    return .init(
      baseURL: baseURL, path: path, method: method, headers: headers,
      authType: authType, contentType: contentType, dataType: dataType
    ) { () -> URLRequest in

      switch method {

      case .get:

        return getRequest(
          url, headers: headers, dataType: dataType, authType: authType,
          contentType: contentType, method: .get
        )

      case .put, .patch, .post:

        return putPatchPostRequest(
          url, headers: headers, dataType: dataType, authType: authType,
          contentType: contentType, method: method
        )

      case .delete:
        return deleteRequest(
          url, headers: headers, dataType: dataType, authType: authType,
          contentType: contentType, method: method
        )
      }
    }
  }

  public func send<D: Decodable, S: Scheduler>(
    urlSession: URLSession = URLSession.shared,
    jsonDecoder: JSONDecoder = .ISO8601JSONDecoder,
    scheduler: S
  ) -> AnyPublisher<D, HTTPRequest.HRError> {

    let request: URLRequest = urlRequest()

    return urlSession.dataTaskPublisher(for: request)
      .assumeHTTP()
      .responseData()
      .decoding(D.self, decoder: jsonDecoder)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<D, HTTPRequest.HRError> in
        return Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: scheduler)
      .eraseToAnyPublisher()
  }
}

// Extension Start Here
extension JSONDecoder {
  public static let ISO8601JSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()
}

extension HTTPRequest {
  var pathAppendedURL: URL {
    var url = baseURL
    url.appendPathComponent(path)
    return url
  }
}
