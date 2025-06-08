//
//  URLRequestInternalExtension.swift
//
//
//  Created by Saroar Khandoker on 01.02.2021.
//

import Foundation

extension URLRequest {
    mutating func setupRequest(headers: HTTPHeaders, method: HTTPRequest.Method) {
        var iterator = headers.makeIterator()
        while let next = iterator.next() {
            setValue(next.value, forHTTPHeaderField: next.name)
        }
        httpMethod = method.rawValue
    }
}
