//
//  APICall.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

protocol APICall {
  var path: String { get }
}

extension APICall {
  func createUrl(baseURL: String) -> URL? {
    return URL(string: baseURL + path)
  }
  
  func createUrl<T>(baseURL: String, paginationState: PaginationState<T>) -> URL? {
    guard var url = createUrl(baseURL: baseURL) else { return nil }
    
    // Append pageLimit and offset to url
    var pageLimit = 0
    
    switch paginationState {
    case .initial(pageLimit: let limit):
      pageLimit = limit
    case .continuing(let paginatedResult, let relationship):
      pageLimit = paginatedResult.limit
      
      if let newPageLink = paginatedResult.getPageLink(for: relationship), newPageLink.count > 0 {
        guard let newUrl = URL(string: newPageLink) else { return nil }
        
        url = newUrl
      }
      
    }
    
    url.appendQuery(parameters: ["per_page": String(pageLimit)])
    
    return url
  }
  
  func createUrlRequest(
    baseURL: String,
    method: HTTPMethod,
    headers: [HTTPHeader]? = nil,
    body: Data? = nil) throws -> URLRequest {
    guard let url = createUrl(baseURL: baseURL) else {
      throw HTTPError.invalidRequest
    }
    
    return createUrlRequest(url: url, method: method, headers: headers, body: body)
  }
  
  func createUrlRequest<T>(
    baseURL: String,
    paginationState: PaginationState<T>,
    method: HTTPMethod,
    headers: [HTTPHeader]? = nil,
    body: Data? = nil) throws -> URLRequest {
    guard let url = createUrl(baseURL: baseURL, paginationState: paginationState) else {
      throw HTTPError.invalidRequest
    }
    
    return createUrlRequest(url: url, method: method, headers: headers, body: body)
  }
  
  private func createUrlRequest(
    url: URL,
    method: HTTPMethod,
    headers: [HTTPHeader]? = nil,
    body: Data? = nil) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    if let headers = headers {
      request.addHeaders(headers)
    }
    request.httpBody = body
    return request
  }
}
