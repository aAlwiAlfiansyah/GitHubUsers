//
//  GitHubUser.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

// MARK: - GitHub User

public struct GitHubUser: Codable, Sendable {
  
  /// The id for this GitHub User resource
  public let id: Int?
  
  /// The username for this GitHub User resource
  public let login: String?
  
  /// The full name for this GitHub User resource
  public let name: String?
 
  /// The avatar URL for this GitHub User resource
  public let avatarURL: String?
  
  /// The repositories URL for this GitHub User resource
  public let reposURL: String?

  /// The type for this GitHub User resource
  public let type: String?
  
  /// The number of followers for this GitHub User resource
  public let followers: Int?

  /// The number of following for this GitHub User resource
  public let following: Int?
}
