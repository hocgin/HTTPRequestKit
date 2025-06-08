//
//  HRError.swift
//  
//
//  Created by Saroar Khandoker on 14.10.2021.
//

import Foundation

extension HTTPRequest {
  public struct HRError: Error, Equatable {

    public static func == (lhs: HTTPRequest.HRError, rhs: HTTPRequest.HRError) -> Bool {
      return lhs.description == rhs.description
    }

    public var description: String
    public let reason: Error?

    public static var nonHTTPResponse: Self {
      .init(description: "Non-HTTP response received", reason: nil)
    }
    public static var irregularError: Self {
      .init(description: "Irregular Error", reason: nil)
    }

    public static var missingTokenFromIOS: Self {
      .init(description: "JWT token are missing on ios app", reason: nil)
    }

    public static func requestFailed(_ statusCode: Int) -> Self {
      return .init(description: "Request Failed HTTP with error - \(statusCode)", reason: nil)
    }

    public static func serverError(_ statusCode: Int) -> Self {
      return .init(description: "Server Error - \(statusCode)", reason: nil)
    }

    public static func networkError(_ error: Error?) -> Self {
      return .init(description: "Failed to load the request: \(String(describing: error))", reason: error)
    }

    public static func authError(_ statusCode: Int) -> Self {
      return .init(description: "Authentication Token is expired: \(statusCode)", reason: nil)
    }

    public static func decodingError(_ decError: DecodingError) -> Self {
      return .init(description: "Failed to process response: \(decError)", reason: decError)
    }

    public static func unhandledResponse(_ statusCode: Int) -> Self {
      return .init(description: "Unhandled HTTP Response Status code: \(statusCode)", reason: nil)
    }

    public static func custom(_ status: String, _ error: Error?) -> Self {
      return .init(description: "\(status)", reason: error)
    }
  }
}
