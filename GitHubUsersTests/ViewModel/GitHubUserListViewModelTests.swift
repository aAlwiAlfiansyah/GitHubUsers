//
//  GitHubUserListViewModelTests.swift
//  GitHubUsersTests
//
//  Created by Alwi Alfiansyah Ramdan on 30/06/25.
//

import XCTest
import Quick
import Nimble
@testable import GitHubUsers

final class GitHubUserListViewModelTests: AsyncSpec {
  
  override class func spec(){
    describe("GitHubUserListViewModel") {
      var gitHubUsersAPI: GitHubUsersAPI!
      var githubUserService: MockedGitHubUserService!
      var githubUserRepoService: MockedGitHubUserRepoService!
      var sut: GitHubUserListViewModel!
      
      beforeEach {
        githubUserService = MockedGitHubUserService()
        githubUserRepoService = MockedGitHubUserRepoService()
        gitHubUsersAPI = GitHubUsersAPI(
          githubUserService: githubUserService,
          githubuserRepoService: githubUserRepoService)
        
        sut = GitHubUserListViewModel(githubUsersAPI: gitHubUsersAPI)
      }
      
      describe("init") {
        it("should setup githubUsers array") {
          expect(sut.githubUsers).to(equal([]))
        }
        
        it("should setup userMap dictionary") {
          expect(sut.userMap).to(equal([:]))
        }
        
        it("should setup hasNext") {
          expect(sut.hasNext).to(beFalse())
        }
      }
      
      describe("fetchInitialGitHubUserList") {
        var data: [GitHubUser]!
        var headerLink: HTTPResponseHeaderLink!
        var pagedObject: PagedObject<GitHubUser>!
        var err: Error!
        
        beforeEach {
          headerLink = HTTPResponseHeaderLink(rawValue: """
            <https://api.github.com/>; rel="next", <https://api.github.com/>; rel="first"
          """)
          data = [
            GitHubUser(
              id: 1,
              login: "adul",
              name: "adul adul",
              avatarUrl: nil,
              reposUrl: nil,
              type: nil,
              followers: nil,
              following: nil),
            GitHubUser(
              id: 2,
              login: "mike",
              name: "mike shinoda",
              avatarUrl: nil,
              reposUrl: nil,
              type: nil,
              followers: nil,
              following: nil),
          ]
          
          pagedObject = PagedObject(from: headerLink, with: .initial(pageLimit: 1), currentUrl: "", results: data)
          
          err = HTTPError.unexpectedResponse
          
        }
        
        it("should set githubUsers array") {
          githubUserService = MockedGitHubUserService(mockPagedObject: pagedObject)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserListViewModel(githubUsersAPI: gitHubUsersAPI)
          
          await sut.fetchInitialGitHubUserList()
          await expect(sut.githubUsers).toEventually(equal(data))
        }
        
        it("should set empty githubUsers array as the fetch failed") {
          githubUserService = MockedGitHubUserService(mockError: err)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserListViewModel(githubUsersAPI: gitHubUsersAPI)
          
          await sut.fetchInitialGitHubUserList()
          await expect(sut.githubUsers).toEventually(equal([]))
        }
      }
      
      describe("fetchMoreGitHubUserList") {
        var data: [GitHubUser]!
        var initialData: [GitHubUser]!
        var headerLink: HTTPResponseHeaderLink!
        var pagedObject: PagedObject<GitHubUser>!
        var err: Error!
        
        beforeEach {
          headerLink = HTTPResponseHeaderLink(rawValue: """
            <https://api.github.com/>; rel="next", <https://api.github.com/>; rel="first"
          """)
          initialData = [
            GitHubUser(
              id: 1,
              login: "adul",
              name: "adul adul",
              avatarUrl: nil,
              reposUrl: nil,
              type: nil,
              followers: nil,
              following: nil),
            GitHubUser(
              id: 2,
              login: "mike",
              name: "mike shinoda",
              avatarUrl: nil,
              reposUrl: nil,
              type: nil,
              followers: nil,
              following: nil),
          ]
          
          data = [
            GitHubUser(
              id: 3,
              login: "dude",
              name: "dude marco",
              avatarUrl: nil,
              reposUrl: nil,
              type: nil,
              followers: nil,
              following: nil),
            GitHubUser(
              id: 4,
              login: "john",
              name: "john ceena",
              avatarUrl: nil,
              reposUrl: nil,
              type: nil,
              followers: nil,
              following: nil),
          ]
          
          pagedObject = PagedObject(from: headerLink, with: .initial(pageLimit: 1), currentUrl: "", results: data)
          
          err = HTTPError.unexpectedResponse
          
        }
        
        it("should update githubUsers array") {
          githubUserService = MockedGitHubUserService(mockPagedObject: pagedObject)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserListViewModel(githubUsersAPI: gitHubUsersAPI)
          sut.githubUsers = initialData
          sut.userMap = [
            initialData[0].id!: initialData[0],
            initialData[1].id!: initialData[1],
          ]
          sut.pagedObject = pagedObject
          
          let expected = initialData + data
          
          await sut.fetchMoreGitHubUserList()
          await expect(sut.githubUsers).toEventually(equal(expected))
        }
        
        it("should not update githubUsers array as the fetch failed") {
          githubUserService = MockedGitHubUserService(mockError: err)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserListViewModel(githubUsersAPI: gitHubUsersAPI)
          sut.githubUsers = initialData
          sut.userMap = [
            initialData[0].id!: initialData[0],
            initialData[1].id!: initialData[1],
          ]
          sut.pagedObject = pagedObject
          
          await sut.fetchMoreGitHubUserList()
          await expect(sut.githubUsers).toEventually(equal(initialData))
        }
      }
    }
  }
}
