//
//  GitHubUserSearchViewModel.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 02/07/25.
//

import Foundation

class GitHubUserSearchViewModel: ObservableObject {
  @Published var githubUsers: [GitHubUser]
  @Published var hasNext: Bool
  @Published var hasPrev: Bool
  
  var pagedObject: PagedObject<GitHubUserSearch>?
  var gitHubUsersAPI: GitHubUsersAPI
  var userMap: [Int: GitHubUser]
  
  init(githubUsersAPI: GitHubUsersAPI) {
    self.githubUsers = []
    self.hasNext = false
    self.hasPrev = false
    self.userMap = [:]
    self.gitHubUsersAPI = githubUsersAPI
    
    print("GitHubUserSearchViewModel => created")
  }
  
  deinit {
    print("GitHubUserSearchViewModel => destroyed")
  }
  
  func resetGitHubUsers() {
    self.githubUsers = []
    self.userMap = [:]
    self.pagedObject = nil
    self.hasNext = false
    self.hasPrev = false
  }
  
  func searchInitialGitHubUser(_ username: String) async {
    do {
      await MainActor.run {
        self.githubUsers = []
        self.userMap = [:]
      }
      
      var searchResult: GitHubUserSearch?
      (self.pagedObject, searchResult) = try await gitHubUsersAPI.githubUserService.searchUserListByUsername(
        username,
        paginationState: .initial(pageLimit: 30))
      
      if let pagedObject = self.pagedObject, let listResult = searchResult?.items {
        for userResourse in listResult {
          if userMap[userResourse.id!] == nil {
            await MainActor.run {
              self.githubUsers.append(userResourse)
              self.userMap[userResourse.id!] = userResourse
            }
          }
        }
        await MainActor.run {
          self.githubUsers.sort {
            $0.id! < $1.id!
          }
          self.hasNext = pagedObject.hasNext
          self.hasPrev = pagedObject.hasPrevious
        }
      }
    } catch {
      await MainActor.run {
        self.githubUsers = []
        self.userMap = [:]
      }
    }
  }
  
  func fetchMoreGitHubUserSearch(_ username: String, _ relation: PaginationRelationship = .next) async {
    do {
      guard let pagedObject = self.pagedObject else { return }
      guard pagedObject.hasNext else { return }
      
      await MainActor.run {
        self.githubUsers = []
        self.userMap = [:]
      }
      
      var searchResult: GitHubUserSearch?
      (self.pagedObject, searchResult) = try await gitHubUsersAPI.githubUserService.searchUserListByUsername(
        username,
        paginationState: .continuing(pagedObject, relation))
      
      guard let pagedObject = self.pagedObject else { return }
      
      if let listResult = searchResult?.items {
        for userResourse in listResult {
          if userMap[userResourse.id!] == nil {
            await MainActor.run {
              self.githubUsers.append(userResourse)
              self.userMap[userResourse.id!] = userResourse
            }
          }
        }
        await MainActor.run {
          self.githubUsers.sort {
            $0.id! < $1.id!
          }
          self.hasNext = pagedObject.hasNext
          self.hasPrev = pagedObject.hasPrevious
        }
      }
    } catch {
      await MainActor.run {
        self.githubUsers = []
        self.userMap = [:]
      }
    }
  }
}
