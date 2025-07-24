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
        var cancellable: AnyCancellable?
        defer { cancellable?.cancel() }

        return try await withCheckedThrowingContinuation { continuation in
            var isResumed = false
            cancellable = self.first().sink(
                receiveCompletion: { completion in
                    guard !isResumed else { return }
                    if case let .failure(error) = completion {
                        isResumed = true
                        continuation.resume(throwing: error)
                    }
                },
                receiveValue: { value in
                    guard !isResumed else { return }
                    isResumed = true
                    continuation.resume(returning: value)
                }
            )
        }
    }
}
