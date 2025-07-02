//
//  HTTPWebService.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

enum HTTPMethod: String {
  case get, post, put, delete, patch, head
}

public protocol HTTPWebService {
  var session: URLSession { get }
  var baseURL: String { get }
}

// MARK: - Completion Calls

extension HTTPWebService {
  func call(
    endpoint: APICall,
    method: HTTPMethod = .get,
    headers: [HTTPHeader]? = nil,
    body: Data? = nil) async throws -> Data {
      let request = try endpoint.createUrlRequest(baseURL: baseURL, method: method, headers: headers, body: body)
      
      guard request.url != nil else {
        throw HTTPError.invalidRequest
      }
      
      let (data, _) = try await session.startData(request)
      
      return data
    }
  
  func callPaginated<T>(
    endpoint: APICall,
    paginationState: PaginationState<T>,
    method: HTTPMethod = .get,
    headers: [HTTPHeader]? = nil,
    body: Data? = nil) async throws -> PagedObject<T> where T: Decodable {
      let request = try endpoint.createUrlRequest(
        baseURL: baseURL,
        paginationState: paginationState,
        method: method,
        headers: headers,
        body: body)
      
      guard let url = request.url else {
        throw HTTPError.invalidRequest
      }
      
      let (data, response) = try await session.startData(request)
      let listObject = try [T].decode(from: data)
      let linkHeader = response.httpResponseHeaderLink
      
      let newPagedObject = PagedObject(
        from: linkHeader,
        with: paginationState,
        currentUrl: url.absoluteString,
        results: listObject)
      
      return newPagedObject
    }
  
  func callSinglePaginated<T>(
    endpoint: APICall,
    paginationState: PaginationState<T>,
    method: HTTPMethod = .get,
    headers: [HTTPHeader]? = nil,
    body: Data? = nil) async throws -> (PagedObject<T>, T) where T: Decodable {
      
      let request = try endpoint.createUrlRequest(
        baseURL: baseURL,
        paginationState: paginationState,
        method: method,
        headers: headers,
        body: body)
      
      guard let url = request.url else {
        throw HTTPError.invalidRequest
      }
      
      let (data, response) = try await session.startData(request)
      let linkHeader = response.httpResponseHeaderLink
      
      let result = try T.decode(from: data)
      
      let newPagedObject = PagedObject(
        from: linkHeader,
        with: paginationState,
        currentUrl: url.absoluteString,
        results: [])
      
      return (newPagedObject, result)
    }
}
