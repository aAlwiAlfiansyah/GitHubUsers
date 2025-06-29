//
//  GitHubUsersAPI.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

public final class GitHubUsersAPI: Sendable {
  public let session: URLSession
  
  public init(
    session: URLSession = URLSession.shared,
    githubUserService: GHUGitHubUserService = GitHubUserService(session: URLSession.shared),
    githubuserRepoService: GHUGitHubUserRepoService = GitHubUserRepoService(session: URLSession.shared)) {
      self.session = session
      
      self.githubUserService = githubUserService
      self.githubUserRepoService = githubuserRepoService
    }
  
  public let githubUserService: GHUGitHubUserService
  public let githubUserRepoService: GHUGitHubUserRepoService
}
