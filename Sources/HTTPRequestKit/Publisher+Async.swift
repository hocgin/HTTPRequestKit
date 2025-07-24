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
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = self
                .first()
                .sink(
                    receiveCompletion: { completion in
                        cancellable?.cancel()
                        switch completion {
                        case .finished:
                            // 如果没有发送 value 就 finished，是 continuation 漏了
                            continuation.resume(throwing: URLError(.badServerResponse))
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    },
                    receiveValue: { value in
                        cancellable?.cancel()
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}
