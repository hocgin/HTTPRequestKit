//
//  DataType.swift
//  
//
//  Created by Saroar Khandoker on 14.10.2021.
//

import Foundation

extension HTTPRequest {
  public struct DataType {
    public init(
      data: Data? = nil,
      queryItems: [URLQueryItem]? = nil,
      parameters: [String : Any]? = nil
    ) {
      self.data = data
      self.queryItems = queryItems
      self.parameters = parameters
    }

    public var data: Data?
    public var queryItems: [URLQueryItem]?
    public var parameters: [String: Any]?

    public static var none: DataType {
      .init(data: nil)
    }

    static public func sendData<T: Encodable>(
      items: [URLQueryItem]? = nil,
      params: [String: Any]? = nil,
      encodable: T? = nil,
      parameters: T? = nil
    ) -> Self {
      if items != nil {
          return .init(queryItems: items!)
      } else if params != nil {
          return .init(parameters: params!)
      } else if encodable != nil {
        return .encodable(input: encodable)
      } else if parameters != nil {
        return .parameters(input: parameters)
      } else {
        return .none
      }
    }

    static public func query(with items: [URLQueryItem] ) -> Self {
      return .init(queryItems: items)
    }

    static public func query(with params: [String: Any]) -> Self {
      return .init(parameters: params)
    }

    static public func encodable<T>(input: T, encoder: JSONEncoder = .init() ) -> Self where T: Encodable {

      do {
        let data = try encoder.encode(input)
        return .init(data: data)
      } catch let error {
        assertionFailure("encodable encoder error: \(error)")
        return .init(data: Data())
      }

    }

    static public func parameters<T>(input: T, encoder: JSONEncoder = .init() ) -> Self {
      do {
        let data = try JSONSerialization.data(withJSONObject: input, options: .prettyPrinted)
        return .init(data: data)
      } catch let error {
        assertionFailure("parameters encoder error: \(error)")
        return .init(data: Data())
      }
    }

  }
}
