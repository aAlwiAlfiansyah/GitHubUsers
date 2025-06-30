//
//  GitHubUserListViewModel.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

class GitHubUserListViewModel: ObservableObject {
  @Published var githubUsers: [GitHubUser]
  @Published var hasNext: Bool
  
  var pagedObject: PagedObject<GitHubUser>?
  var gitHubUsersAPI: GitHubUsersAPI
  var userMap: [Int: GitHubUser]
  
  init(githubUsersAPI: GitHubUsersAPI) {
    self.githubUsers = []
    self.hasNext = false
    self.userMap = [:]
    self.gitHubUsersAPI = githubUsersAPI
    
    print("GitHubUserListViewModel => created")
  }
  
  deinit {
    print("GitHubUserListViewModel => destroyed")
  }
  
  func fetchInitialGitHubUserList() async {
    do {
      await MainActor.run {
        self.githubUsers = []
        self.userMap = [:]
      }
      
      self.pagedObject = try await gitHubUsersAPI.githubUserService.fetchUserList(
        paginationState: .initial(pageLimit: 30)
      )
      
      if let pagedObject = self.pagedObject, let listResult = pagedObject.results {
        
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
        }
      }
    } catch {
      await MainActor.run {
        self.githubUsers = []
        self.userMap = [:]
      }
    }
  }
  
  func fetchMoreGitHubUserList() async {
    
    do {
      guard let pagedObject = self.pagedObject else { return }
      guard pagedObject.hasNext else { return }
      
      self.pagedObject = try await gitHubUsersAPI.githubUserService.fetchUserList(
        paginationState: .continuing(pagedObject, .next)
      )
      
      guard let pagedObject = self.pagedObject else { return }
      
      if let listResult = pagedObject.results {
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
        }
      }
    } catch {
      // Do Nothing
    }
  }
}
