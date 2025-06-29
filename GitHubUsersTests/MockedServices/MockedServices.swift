//
//  MockedServices.swift
//  GitHubUsersTests
//
//  Created by Alwi Alfiansyah Ramdan on 30/06/25.
//

import Foundation
@testable import GitHubUsers

class MockURLProtocol: URLProtocol {
  static var mockResponses: [URL: (data: Data?, response: URLResponse?, error: Error?)] = [:]
  
  static func reset() {
    mockResponses = [:]
  }

  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override func startLoading() {
    if let url = request.url,
       let mockResponse = MockURLProtocol.mockResponses[url] {
      if let responseError = mockResponse.error {
        client?.urlProtocol(self, didFailWithError: responseError)
        client?.urlProtocolDidFinishLoading(self)
        return
      }
      
      if let responseData = mockResponse.data {
        client?.urlProtocol(self, didLoad: responseData)
      }
      
      if let response = mockResponse.response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      
      client?.urlProtocolDidFinishLoading(self)
    }
  }

  override func stopLoading() {}
}

struct MockedGitHubUserService: GHUGitHubUserService {
  var session: URLSession {
    if let mockSession = mockUrlSession {
      return mockSession
    }
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
  }
  var baseURL: String {
    if let url = mockBaseURL {
      return url
    }
    
    return ""
  }
  
  var mockGitHubUser: GitHubUser?
  var mockPagedObject: PagedObject<GitHubUser>?
  var mockError: Error?
  var mockUrlSession: URLSession?
  var mockBaseURL: String?
  
  func fetchUserList(paginationState: PaginationState<GitHubUser>) async throws -> PagedObject<GitHubUser> {
    if let pagedObject = mockPagedObject {
      return pagedObject
    }
    
    if let error = mockError {
      throw error
    }
    
    return PagedObject(from: nil, with: .initial(pageLimit: 1), currentUrl: "", results: [])
  }
  
  func fetchUser(_ username: String) async throws -> GitHubUser {
    if let user = mockGitHubUser {
      return user
    }
    
    if let error = mockError {
      throw error
    }

    return GitHubUser(
      id: nil,
      login: nil,
      name: nil,
      avatarUrl: nil,
      reposUrl: nil,
      type: nil,
      followers: nil,
      following: nil)
  }
  
}

struct MockedGitHubUserRepoService: GHUGitHubUserRepoService {
  var session: URLSession {
    if let mockSession = mockUrlSession {
      return mockSession
    }
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
  }
  var baseURL: String {
    if let url = mockBaseURL {
      return url
    }
    
    return ""
  }
  
  var mockPagedObject: PagedObject<GitHubRepo>?
  var mockError: Error?
  var mockUrlSession: URLSession?
  var mockBaseURL: String?
  
  func fetchUserRepoList(_ username: String, paginationState: PaginationState<GitHubRepo>) async throws -> PagedObject<GitHubRepo> {
    
    if let pagedObject = mockPagedObject {
      return pagedObject
    }
    
    if let error = mockError {
      throw error
    }
    
    return PagedObject(from: nil, with: .initial(pageLimit: 1), currentUrl: "", results: [])
  }
}
