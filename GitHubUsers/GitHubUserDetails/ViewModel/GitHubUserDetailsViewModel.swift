//
//  GitHubUserDetailsViewModel.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 29/06/25.
//

import Foundation

class GitHubUserDetailsViewModel: ObservableObject {
  @Published var githubUser: GitHubUser
  @Published var githubRepos: [GitHubRepo]
  @Published var hasNext: Bool
  
  var pagedObject: PagedObject<GitHubRepo>?
  var gitHubUsersAPI: GitHubUsersAPI
  var repoMap: [Int: GitHubRepo]
  
  init(githubUser: GitHubUser, gitHubUsersAPI: GitHubUsersAPI) {
    self.githubUser = githubUser
    self.gitHubUsersAPI = gitHubUsersAPI
    
    self.githubRepos = []
    self.repoMap = [:]
    self.hasNext = false
    
    print("GitHubUserDetailsViewModel => created")
  }
  
  deinit {
    print("GitHubUserDetailsViewModel => destroyed")
  }
  
  func fetchUserDetailsInfo() async {
    do {
      let user = try await gitHubUsersAPI.githubUserService.fetchUser(githubUser.login!)
      
      await MainActor.run {
        self.githubUser = user
      }
    } catch {
      // Do nothing for now
    }
  }
  
  func fetchInitialGitHubUserRepoList() async {
    do {
      await MainActor.run {
        self.githubRepos = []
        self.repoMap = [:]
      }
      
      self.pagedObject = try await gitHubUsersAPI.githubUserRepoService.fetchUserRepoList(githubUser.login!, paginationState: .initial(pageLimit: 30))
      
      if let pagedObject = self.pagedObject, let listResult = pagedObject.results {
        for repoResourse in listResult {
          let isForked: Bool = repoResourse.fork ?? false
          if repoMap[repoResourse.id!] == nil && !isForked {
            await MainActor.run {
              self.githubRepos.append(repoResourse)
              self.repoMap[repoResourse.id!] = repoResourse
            }
          }
        }
        await MainActor.run {
          self.githubRepos.sort {
            $0.id! < $1.id!
          }
          self.hasNext = pagedObject.hasNext
        }
      }
    } catch {
      await MainActor.run {
        self.githubRepos = []
        self.repoMap = [:]
      }
    }
  }
  
}

