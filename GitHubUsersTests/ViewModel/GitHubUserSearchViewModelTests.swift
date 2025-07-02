//
//  GitHubUserSearchViewModelTests.swift
//  GitHubUsersTests
//
//  Created by Alwi Alfiansyah Ramdan on 02/07/25.
//

import XCTest
import Quick
import Nimble
@testable import GitHubUsers

// swiftlint:disable function_body_length
final class GitHubUserSearchViewModelTests: AsyncSpec {
  override class func spec() {
    describe("GitHubUserSearchViewModel") {
      var gitHubUsersAPI: GitHubUsersAPI!
      var githubUserService: MockedGitHubUserService!
      var githubUserRepoService: MockedGitHubUserRepoService!
      var sut: GitHubUserSearchViewModel!
      
      var username: String!
      
      beforeEach {
        githubUserService = MockedGitHubUserService()
        githubUserRepoService = MockedGitHubUserRepoService()
        gitHubUsersAPI = GitHubUsersAPI(
          githubUserService: githubUserService,
          githubuserRepoService: githubUserRepoService)
        
        sut = GitHubUserSearchViewModel(githubUsersAPI: gitHubUsersAPI)
        
        username = "adul"
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
        
        it("should setup hasPrev") {
          expect(sut.hasPrev).to(beFalse())
        }
        
        it("should setup pagedObject") {
          expect(sut.pagedObject).to(beNil())
        }
      }
      
      describe("fetchInitialGitHubUserList") {
        var data: [GitHubUser]!
        var headerLink: HTTPResponseHeaderLink!
        var pagedObject: PagedObject<GitHubUserSearch>!
        var searchData: GitHubUserSearch!
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
              login: "adul mage",
              name: "adul mage",
              avatarUrl: nil,
              reposUrl: nil,
              type: nil,
              followers: nil,
              following: nil)
          ]
          
          pagedObject = PagedObject(
            from: headerLink,
            with: .initial(pageLimit: 1),
            currentUrl: "",
            results: [])
          
          searchData = GitHubUserSearch(
            totalCount: 100,
            incompleteResults: true,
            items: data)
          
          err = HTTPError.unexpectedResponse
        }
        
        it("should set githubUsers array") {
          githubUserService = MockedGitHubUserService(mockGitHubUserSearch: searchData, mockSearchPagedObject: pagedObject)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserSearchViewModel(githubUsersAPI: gitHubUsersAPI)
          
          await sut.searchInitialGitHubUser(username)
          expect(sut.githubUsers).to(equal(data))
          expect(sut.userMap).notTo(beEmpty())
          expect(sut.hasNext).to(beTrue())
          expect(sut.hasPrev).to(beFalse())
        }
        
        it("should set empty githubUsers array as the fetch failed") {
          githubUserService = MockedGitHubUserService(mockError: err)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserSearchViewModel(githubUsersAPI: gitHubUsersAPI)
          
          await sut.searchInitialGitHubUser(username)
          expect(sut.githubUsers).to(beEmpty())
          expect(sut.userMap).to(beEmpty())
          expect(sut.hasNext).to(beFalse())
          expect(sut.hasPrev).to(beFalse())
        }
      }
      
      describe("fetchMoreGitHubUserSearch") {
        var data: [GitHubUser]!
        var initialData: [GitHubUser]!
        var headerLink: HTTPResponseHeaderLink!
        var pagedObject: PagedObject<GitHubUserSearch>!
        var searchData: GitHubUserSearch!
        var err: Error!
        
        beforeEach {
          username = "dude"
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
              following: nil)
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
              login: "dude",
              name: "dude ceena",
              avatarUrl: nil,
              reposUrl: nil,
              type: nil,
              followers: nil,
              following: nil)
          ]
          
          pagedObject = PagedObject(
            from: headerLink,
            with: .initial(pageLimit: 1),
            currentUrl: "",
            results: [])
          searchData = GitHubUserSearch(
            totalCount: 100,
            incompleteResults: true,
            items: data)
          
          err = HTTPError.unexpectedResponse
          
        }
        
        it("should update githubUsers array") {
          githubUserService = MockedGitHubUserService(mockGitHubUserSearch: searchData, mockSearchPagedObject: pagedObject)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserSearchViewModel(githubUsersAPI: gitHubUsersAPI)
          sut.githubUsers = initialData
          sut.userMap = [
            initialData[0].id!: initialData[0],
            initialData[1].id!: initialData[1]
          ]
          sut.pagedObject = pagedObject
          
          await sut.fetchMoreGitHubUserSearch(username, .next)
          expect(sut.githubUsers).to(equal(data))
          expect(sut.userMap.count).to(equal(2))
          expect(sut.hasNext).to(beTrue())
          expect(sut.hasPrev).to(beFalse())
        }
        
        it("should reset githubUsers array as the fetch failed") {
          githubUserService = MockedGitHubUserService(mockError: err)
          gitHubUsersAPI = GitHubUsersAPI(
            githubUserService: githubUserService,
            githubuserRepoService: githubUserRepoService)
          sut = GitHubUserSearchViewModel(githubUsersAPI: gitHubUsersAPI)
          sut.githubUsers = initialData
          sut.userMap = [
            initialData[0].id!: initialData[0],
            initialData[1].id!: initialData[1]
          ]
          sut.pagedObject = pagedObject
          
          await sut.fetchMoreGitHubUserSearch(username, .next)
          expect(sut.githubUsers).to(beEmpty())
          expect(sut.userMap).to(beEmpty())
          expect(sut.hasNext).to(beFalse())
          expect(sut.hasPrev).to(beFalse())
        }
      }
    }
  }
  
}
// swiftlint:enable function_body_length
