//
//  URLRequestInternalExtension.swift
//
//
//  Created by Saroar Khandoker on 01.02.2021.
//

import Foundation

extension URLRequest {
    private var headerField: String { "Authorization" }
    private var contentTypeHeader: String { "Content-Type" }

    mutating func setupRequest(
        headers: [String: String]?,
        authType: HTTPRequest.AuthType,
        contentType: HTTPRequest.ContentType,
        method: HTTPRequest.Method
    ) {
        let contentTypeHeaderName = contentTypeHeader
        allHTTPHeaderFields = headers
        if contentType != .none {
            setValue(contentType.content, forHTTPHeaderField: contentTypeHeaderName)
        }
        setupAuthorization(with: authType)
        httpMethod = method.rawValue
    }

    mutating func setupAuthorization(with authType: HTTPRequest.AuthType) {
        switch authType {
        case let .basic(username, password):
            let loginString = String(format: "%@:%@", username, password)
            guard let data = loginString.data(using: .utf8) else { return }
            setValue("Basic \(data.base64EncodedString())", forHTTPHeaderField: headerField)
        case let .bearer(token):
            setValue("Bearer \(token)", forHTTPHeaderField: headerField)
        case .none: break
        }
    }
}
