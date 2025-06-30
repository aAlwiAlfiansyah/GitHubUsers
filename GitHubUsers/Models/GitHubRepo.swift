//
//  GitHubRepo.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

// MARK: - GitHub Repo

public struct GitHubRepo: Codable, Sendable, Hashable {
  
  /// The id for this GitHub Repo resource
  public let id: Int?
  
  /// The name for this GitHub Repo resource
  public let name: String?

  /// The description for this GitHub Repo resource
  public let description: String?
  
  /// The forking status for this GitHub Repo resource
  public let fork: Bool?
  
  /// The URL for this GitHub Repo resource
  public let htmlUrl: String?

  /// The programming language for this GitHub Repo resource
  public let language: String?

  /// The number of star gazers for this GitHub Repo resource
  public let stargazersCount: Int?
  
  init(
    id: Int?,
    name: String?,
    description: String?,
    fork: Bool?,
    htmlUrl: String?,
    language: String?,
    stargazersCount: Int?) {
    self.id = id
    self.name = name
    self.description = description
    self.fork = fork
    self.htmlUrl = htmlUrl
    self.language = language
    self.stargazersCount = stargazersCount
  }
}
