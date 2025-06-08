//
//  ContentType.swift
//
//
//  Created by Saroar Khandoker on 14.10.2021.
//

import Foundation

@available(*, deprecated, renamed: "x", message: "x")
public extension HTTPRequest {
    struct ContentType: Equatable {
        public var content: String

        public static var json: Self {
            .init(content: "application/json")
        }

        public static var urlFormEncoded: Self {
            .init(content: "application/x-www-form-urlencoded")
        }

        public static var multipartFormData: Self {
            .init(content: "multipart/form-data")
        }

        public static var none: Self {
            .init(content: "")
        }
    }
}
