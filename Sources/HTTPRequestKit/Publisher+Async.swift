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
            var isResumed = false

            cancellable = self.first().sink(
                receiveCompletion: { completion in
                    guard !isResumed else { return }
                    isResumed = true

                    cancellable?.cancel() // ✅ 放到 resume 后面
                    if case let .failure(error) = completion {
                        continuation.resume(throwing: error)
                    }
                },
                receiveValue: { value in
                    guard !isResumed else { return }
                    isResumed = true

                    cancellable?.cancel() // ✅ 放到 resume 后面
                    continuation.resume(returning: value)
                }
            )
        }
    }
}
