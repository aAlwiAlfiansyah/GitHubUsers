//
//  GitHubUsersAPI.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

public final class GitHubUsersAPI: Sendable {
    public let session: URLSession
    
    public init(session: URLSession = URLSession.shared) {
        self.session = session
        
        githubUserService = GitHubUserService(session: session)
    }
    
    public let githubUserService: GitHubUserService
}
