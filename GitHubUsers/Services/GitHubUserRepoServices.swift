//
//  GitHubUserRepoServices.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 29/06/25.
//

import Foundation

public protocol GHUGitHubUserRepoService: HTTPWebService, Sendable {
  func fetchUserRepoList(_ username: String, paginationState: PaginationState<GitHubRepo>) async throws -> PagedObject<GitHubRepo>
}


// MARK: - Web Services

public struct GitHubUserRepoService: GHUGitHubUserRepoService, Sendable {
  public enum API: APICall {
    case fetchUserRepoList(String)
    
    var path: String {
      switch self {
      case .fetchUserRepoList(let name):
        return "/users/\(name)/repos"
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
  public func fetchUserRepoList(_ username: String, paginationState: PaginationState<GitHubRepo> = .initial(pageLimit: 30)) async throws -> PagedObject<GitHubRepo> {
    try await callPaginated(endpoint: API.fetchUserRepoList(username), paginationState: paginationState, headers: setupDefaultHeader())
  }
  
  
  /// Helper function for create a default http header for accept and auth bearer
  private func setupDefaultHeader() -> [HTTPHeader] {
    var headers: [HTTPHeader] = []
    headers.append(HTTPHeader.accept(.json))
    headers.append(HTTPHeader.authorizationBearer(APIConfig.githubAccessToken))
    
    return headers
  }
}
