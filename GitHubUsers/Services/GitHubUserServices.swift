//
//  GitHubUser.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

protocol GHUGitHubUserService: HTTPWebService {
  func fetchUserList(paginationState: PaginationState<GitHubUser>) async throws -> PagedObject<GitHubUser>
  func fetchUser(_ userId: Int) async throws -> GitHubUser
}

// MARK: - Web Services

public struct GitHubUserService: GHUGitHubUserService, Sendable {
  public enum API: APICall {
    case fetchUserList
    case fetchUserByName(String)
    case fetchUserById(Int)
    
    var path: String {
      switch self {
      case .fetchUserList:
        return "/users"
      case .fetchUserByName(let name):
        return "/users/\(name)"
      case .fetchUserById(let id):
        return "/users/\(id)"
      }
    }
  }
  
  public var session: URLSession
  
  public var baseURL: String = "https://api.github.com"
  
  
  /**
   Fetch GitHub User list
   */
  public func fetchUserList(paginationState: PaginationState<GitHubUser> = .initial(pageLimit: 30)) async throws -> PagedObject<GitHubUser> {
    try await callPaginated(endpoint: API.fetchUserList, paginationState: paginationState, headers: setupDefaultHeader())
  }
  
  /**
   Fetch GitHub User details
   */
  func fetchUser(_ userId: Int) async throws -> GitHubUser {
    try await GitHubUser.decode(from: call(endpoint: API.fetchUserById(userId), headers: setupDefaultHeader()))
  }
  
  
  private func setupDefaultHeader() -> [HTTPHeader] {
    var headers: [HTTPHeader] = []
    headers.append(HTTPHeader.accept(.json))
    headers.append(HTTPHeader.authorizationBearer(APIConfig.githubAccessToken))
    
    return headers
  }
}
