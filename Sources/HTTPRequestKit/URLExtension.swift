//
//  URLExtension.swift
//  
//
//  Created by Saroar Khandoker on 01.02.2021.
//

import Foundation

extension URL {

  private func generateUrl(withQuery queryItems: [URLQueryItem]) -> URL {
    var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
    urlComponents.queryItems = queryItems
    guard let url = urlComponents.url else { fatalError("Wrong URL Provided") }
    return url
  }

  private func generateUrl(withParams parameters: [String: Any]) -> URL {
      var quearyItems: [URLQueryItem] = []
      for parameter in parameters {
          quearyItems.append(URLQueryItem(name: parameter.key, value: parameter.value as? String))
      }
      var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
      urlComponents.queryItems = quearyItems
      guard let url = urlComponents.url else { fatalError("Wrong URL Provided") }
      return url
  }

  public func queryWith(items: [URLQueryItem]? = nil, params: [String: Any]? = nil) -> Self {
    if let items = items {
      return generateUrl(withQuery: items)
    } else if let params = params {
      return generateUrl(withParams: params)
    } else {
      return self
    }
  }
}
