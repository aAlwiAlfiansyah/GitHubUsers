//
//  GitHubUserDetailsViewModelTests.swift
//  GitHubUsersTests
//
//  Created by Alwi Alfiansyah Ramdan on 30/06/25.
//

import XCTest
import Quick
import Nimble
@testable import GitHubUsers

// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
final class GitHubUserDetailsViewModelTests: AsyncSpec {
  override class func spec() {
    describe("GitHubUserDetailsViewModel") {
      var gitHubUsersAPI: GitHubUsersAPI!
      var githubUserService: MockedGitHubUserService!
      var githubUserRepoService: MockedGitHubUserRepoService!
      var sut: GitHubUserDetailsViewModel!
      var githubUser: GitHubUser!
      
      beforeEach {
        githubUserService = MockedGitHubUserService()
        githubUserRepoService = MockedGitHubUserRepoService()
        gitHubUsersAPI = GitHubUsersAPI(
          githubUserService: githubUserService,
          githubuserRepoService: githubUserRepoService)
        
        githubUser = GitHubUser(
          id: 23,
          login: "adul",
          name: nil,
          avatarUrl: "some avatar",
          reposUrl: nil,
          type: nil,
          followers: nil,
          following: nil)
        
        sut = GitHubUserDetailsViewModel(githubUser: githubUser, gitHubUsersAPI: gitHubUsersAPI)
      }
      
      describe("init") {
        it("should setup githubRepos array") {
          expect(sut.githubRepos).to(equal([]))
        }
        
        it("should setup repoMap dictionary") {
          expect(sut.repoMap).to(equal([:]))
        }
        
        it("should setup hasNext") {
          expect(sut.hasNext).to(beFalse())
        }
      }
      
      describe("fetchUserDetailsInfo") {
        var data: GitHubUser!
        var err: Error!
        
        beforeEach {
          data = GitHubUser(
            id: 23,
            login: "adul",
            name: "adul adul",
            avatarUrl: "some avatar",
            reposUrl: "some repo url",
            type: "User",
            followers: 20,
            following: 3)
          
          err = HTTPError.unexpectedResponse
        }
        
        it("should set githubUser value to the new one") {
          githubUserService = MockedGitHubUserService(mockGitHubUser: data)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserDetailsViewModel(githubUser: githubUser, gitHubUsersAPI: gitHubUsersAPI)
          
          await sut.fetchUserDetailsInfo()
          await expect(sut.githubUser.id).toEventually(equal(data.id))
          await expect(sut.githubUser.login).toEventually(equal(data.login))
          await expect(sut.githubUser.name).toEventually(equal(data.name))
          await expect(sut.githubUser.avatarUrl).toEventually(equal(data.avatarUrl))
          await expect(sut.githubUser.reposUrl).toEventually(equal(data.reposUrl))
          await expect(sut.githubUser.type).toEventually(equal(data.type))
          await expect(sut.githubUser.followers).toEventually(equal(data.followers))
          await expect(sut.githubUser.following).toEventually(equal(data.following))
          
        }
        
        it("should not set githubUser value to the new one  as the fetch failed") {
          githubUserService = MockedGitHubUserService(mockError: err)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserDetailsViewModel(githubUser: githubUser, gitHubUsersAPI: gitHubUsersAPI)
          
          await sut.fetchUserDetailsInfo()
          await expect(sut.githubUser.id).toEventually(equal(data.id))
          await expect(sut.githubUser.login).toEventually(equal(data.login))
          await expect(sut.githubUser.name).toEventually(beNil())
          await expect(sut.githubUser.avatarUrl).toEventually(equal(data.avatarUrl))
          await expect(sut.githubUser.reposUrl).toEventually(beNil())
          await expect(sut.githubUser.type).toEventually(beNil())
          await expect(sut.githubUser.followers).toEventually(beNil())
          await expect(sut.githubUser.following).toEventually(beNil())
          
        }
      }
      
      describe("fetchInitialGitHubUserRepoList") {
        var data: [GitHubRepo]!
        var headerLink: HTTPResponseHeaderLink!
        var pagedObject: PagedObject<GitHubRepo>!
        var err: Error!
        
        var data1: GitHubRepo!
        var data2: GitHubRepo!
        var data3: GitHubRepo!
        var data4: GitHubRepo!
        
        beforeEach {
          headerLink = HTTPResponseHeaderLink(rawValue: """
            <https://api.github.com/>; rel="next", <https://api.github.com/>; rel="first"
          """)
          
          data1 = GitHubRepo(
            id: 1,
            name: "repo 1",
            description: "description for repo 1",
            fork: false,
            htmlUrl: "some html url 1",
            language: "Javascript",
            stargazersCount: 12)
          
          data2 = GitHubRepo(
            id: 2,
            name: "repo 2",
            description: "description for repo 2",
            fork: true,
            htmlUrl: "some html url 2",
            language: "Java",
            stargazersCount: 21)
          
          data3 = GitHubRepo(
            id: 3,
            name: "repo 3",
            description: "description for repo 3",
            fork: false,
            htmlUrl: "some html url 3",
            language: "Ruby",
            stargazersCount: 430)
          
          data4 = GitHubRepo(
            id: 4,
            name: "repo 4",
            description: "description for repo 4",
            fork: false,
            htmlUrl: "some html url 4",
            language: "Swift",
            stargazersCount: 1253)
          
          data = [data1, data2, data3, data4]
          
          pagedObject = PagedObject(from: headerLink, with: .initial(pageLimit: 1), currentUrl: "", results: data)
          
          err = HTTPError.unexpectedResponse
        }
        
        it("should set githubRepo array") {
          githubUserRepoService = MockedGitHubUserRepoService(mockPagedObject: pagedObject)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserDetailsViewModel(githubUser: githubUser, gitHubUsersAPI: gitHubUsersAPI)
          
          let expected = [data1, data3, data4]
          
          await sut.fetchInitialGitHubUserRepoList()
          await expect(sut.githubRepos).toEventually(equal(expected))
        }
        
        it("should not set githubRepo array as fetching failed") {
          githubUserRepoService = MockedGitHubUserRepoService(mockError: err)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserDetailsViewModel(githubUser: githubUser, gitHubUsersAPI: gitHubUsersAPI)
          
          await sut.fetchInitialGitHubUserRepoList()
          await expect(sut.githubRepos).toEventually(equal([]))
        }
      }
      
      describe("fetchMoreGitHubUserRepoList") {
        var data: [GitHubRepo]!
        var initialRepos: [GitHubRepo]!
        var headerLink: HTTPResponseHeaderLink!
        var pagedObject: PagedObject<GitHubRepo>!
        var err: Error!
        
        var data1: GitHubRepo!
        var data2: GitHubRepo!
        var data3: GitHubRepo!
        var data4: GitHubRepo!
        var data5: GitHubRepo!
        
        beforeEach {
          headerLink = HTTPResponseHeaderLink(rawValue: """
            <https://api.github.com/>; rel="next", <https://api.github.com/>; rel="first"
          """)
          
          data1 = GitHubRepo(
            id: 1,
            name: "repo 1",
            description: "description for repo 1",
            fork: false,
            htmlUrl: "some html url 1",
            language: "Javascript",
            stargazersCount: 12)
          
          data2 = GitHubRepo(
            id: 2,
            name: "repo 2",
            description: "description for repo 2",
            fork: false,
            htmlUrl: "some html url 2",
            language: "Java",
            stargazersCount: 21)
          
          data3 = GitHubRepo(
            id: 3,
            name: "repo 3",
            description: "description for repo 3",
            fork: false,
            htmlUrl: "some html url 3",
            language: "Ruby",
            stargazersCount: 430)
          
          data4 = GitHubRepo(
            id: 4,
            name: "repo 4",
            description: "description for repo 4",
            fork: true,
            htmlUrl: "some html url 4",
            language: "Swift",
            stargazersCount: 1253)
          
          data5 = GitHubRepo(
            id: 5,
            name: "repo 5",
            description: "description for repo 5",
            fork: false,
            htmlUrl: "some html url 5",
            language: "Kotlin",
            stargazersCount: 5422)
          
          initialRepos = [data1, data2]
          data = [data3, data4, data5]
          
          pagedObject = PagedObject(from: headerLink, with: .initial(pageLimit: 1), currentUrl: "", results: data)
          
          err = HTTPError.unexpectedResponse
        }
        
        it("should update githubRepo array") {
          githubUserRepoService = MockedGitHubUserRepoService(mockPagedObject: pagedObject)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserDetailsViewModel(githubUser: githubUser, gitHubUsersAPI: gitHubUsersAPI)
          sut.githubRepos = initialRepos
          sut.repoMap = [
            initialRepos[0].id!: initialRepos[0],
            initialRepos[1].id!: initialRepos[1]
          ]
          sut.pagedObject = pagedObject
          
          var expected: [GitHubRepo] = initialRepos
          expected.append(data3)
          expected.append(data5)
          
          await sut.fetchMoreGitHubUserRepoList()
          await expect(sut.githubRepos).toEventually(equal(expected))
        }
        
        it("should not update githubRepo array as the fetch failed") {
          githubUserRepoService = MockedGitHubUserRepoService(mockError: err)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserDetailsViewModel(githubUser: githubUser, gitHubUsersAPI: gitHubUsersAPI)
          sut.githubRepos = initialRepos
          sut.repoMap = [
            initialRepos[0].id!: initialRepos[0],
            initialRepos[1].id!: initialRepos[1]
          ]
          sut.pagedObject = pagedObject
          
          await sut.fetchMoreGitHubUserRepoList()
          await expect(sut.githubRepos).toEventually(equal(initialRepos))
        }
      }
    }
  }
  
}
// swiftlint:enable type_body_length
// swiftlint:enable function_body_length
