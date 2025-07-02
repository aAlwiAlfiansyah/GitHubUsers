//
//  GitHubUserService.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

public protocol GHUGitHubUserService: HTTPWebService, Sendable {
  func fetchUserList(
    paginationState: PaginationState<GitHubUser>
  ) async throws -> PagedObject<GitHubUser>
  func fetchUser(_ username: String) async throws -> GitHubUser
}

// MARK: - Web Services

public struct GitHubUserService: GHUGitHubUserService, Sendable {
  public enum API: APICall {
    case fetchUserList
    case fetchUserByUsername(String)
    
    var path: String {
      switch self {
      case .fetchUserList:
        return "/users"
      case .fetchUserByUsername(let name):
        return "/users/\(name)"
      }
    }
  }
  
  public var session: URLSession
  
  public var baseURL: String = "https://api.github.com"
  
  /// Initializer
  public init(session: URLSession) {
    self.session = session
  }
  
  /**
   Fetch GitHub User list
   */
  public func fetchUserList(
    paginationState: PaginationState<GitHubUser> = .initial(pageLimit: 30)
  ) async throws -> PagedObject<GitHubUser> {
    try await callPaginated(
      endpoint: API.fetchUserList,
      paginationState: paginationState,
      headers: setupDefaultHeader())
  }
  
  /**
   Fetch GitHub User details
   */
  public func fetchUser(_ username: String) async throws -> GitHubUser {
    try await GitHubUser.decode(
      from: call(
        endpoint: API.fetchUserByUsername(username),
        headers: setupDefaultHeader()
      ))
  }
  
  /// Helper function for create a default http header for accept and auth bearer
  private func setupDefaultHeader() -> [HTTPHeader] {
    var headers: [HTTPHeader] = []
    headers.append(HTTPHeader.accept(.json))
    headers.append(HTTPHeader.authorizationBearer(APIConfig.githubAccessToken))
    
    return headers
  }
}
