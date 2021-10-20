//
//  AuthType.swift
//  
//
//  Created by Saroar Khandoker on 14.10.2021.
//

import Foundation

extension HTTPRequest {
  public enum AuthType {
    case bearer(token: String)
    case basic(username: String, password: String)
    case none
  }
}
