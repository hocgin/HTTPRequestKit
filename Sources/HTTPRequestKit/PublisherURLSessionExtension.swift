//
//  PublisherURLSessionExtension.swift
//
//
//  Created by Saroar Khandoker on 01.02.2021.
//

import Combine
import Foundation

public extension Publisher where Output == (data: Data, response: URLResponse) {
    func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPRequest.HRError> {
        tryMap { (data: Data, response: URLResponse) in
            guard let http = response as? HTTPURLResponse else { throw HTTPRequest.HRError.nonHTTPResponse }
            return (data, http)
        }
        .mapError { error in
            if error is HTTPRequest.HRError {
                // swiftlint:disable force_cast
                return error as! HTTPRequest.HRError
            } else {
                return HTTPRequest.HRError.networkError(error)
            }
        }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HTTPRequest.HRError {
    func responseData() -> AnyPublisher<Data, HTTPRequest.HRError> {
        tryMap { (data: Data, response: HTTPURLResponse) -> Data in
            switch response.statusCode {
            case 200...299: return data
            case 401, 403:
                // wait code
                throw HTTPRequest.HRError.authError(response.statusCode)
            case 400...499: throw HTTPRequest.HRError.requestFailed(response.statusCode)
            case 500...599: throw HTTPRequest.HRError.serverError(response.statusCode)
            default:
                throw HTTPRequest.HRError.unhandledResponse(response.statusCode)
            }
        }
        .mapError { $0 as! HTTPRequest.HRError }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HTTPRequest.HRError {
    func retryLimit(when: @escaping () -> Bool) -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPRequest.HRError> {
        map { data, response in
            Swift.print("No more errors...")
            return (data: data, response: response)
        }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == Data, Failure == HTTPRequest.HRError {
    func decoding<D: Decodable, Decoder: TopLevelDecoder>(
        _ type: D.Type,
        decoder: Decoder
    ) -> AnyPublisher<D, HTTPRequest.HRError> where Decoder.Input == Data {
        decode(type: D.self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    return HTTPRequest.HRError.decodingError(error as! DecodingError)
                } else {
                    return error as! HTTPRequest.HRError
                }
            }
            .eraseToAnyPublisher()
    }
}
