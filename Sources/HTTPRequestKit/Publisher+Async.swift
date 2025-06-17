//
//  Publisher+async.swift
//  HTTPRequestKit
//
//  Created by hocgin on 2025/6/9.
//

import Combine
import Foundation

public extension Publisher where Output: Sendable, Failure == Error {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(throwing: HTTPRequest.HRError.nonHTTPResponse)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }

//    func async() async throws -> Output {
//        var cancellable: AnyCancellable?
//        defer { cancellable?.cancel() }
//
//
//
//        return try await withCheckedThrowingContinuation { continuation in
//            cancellable = self.first().sink(
//                receiveCompletion: { completion in
//                    if case let .failure(error) = completion {
//                        continuation.resume(throwing: error)
//                    }
//                },
//                receiveValue: { value in
//                    continuation.resume(returning: value)
//                }
//            )
//        }
//    }
}
