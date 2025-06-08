//
//  AuthType.swift
//
//
//  Created by Saroar Khandoker on 14.10.2021.
//

import Foundation

@available(*, deprecated, renamed: "x", message: "x")
extension HTTPRequest {
    public enum AuthType {
        case bearer(token: String)
        case basic(username: String, password: String)
        case none
    }
}
