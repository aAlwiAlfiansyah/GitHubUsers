//
//  GitHubUserServiceTests.swift
//  GitHubUsersTests
//
//  Created by Alwi Alfiansyah Ramdan on 02/07/25.
//

import XCTest
import Quick
import Nimble
@testable import GitHubUsers

// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
final class GitHubUserServiceTests: AsyncSpec {
  
  override class func spec() {
    describe("GitHubUserService") {
      var urlSession: URLSession!
      var sut: GitHubUserService!
      
      beforeEach {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: config)
        sut = GitHubUserService(session: urlSession)
        MockURLProtocol.reset()
      }
      
      describe("init") {
        it("should set url session") {
          expect(sut.session).to(equal(urlSession))
        }
        
        it("should have correct base URL") {
          expect(sut.baseURL).to(equal("https://api.github.com"))
        }
      }
      
      describe("fetchUser") {
        context("when the request is successful") {
          it("should return correct GitHubUser") {
            let username: String = "mojombo"
            let userId: Int = 1
            let avatar: String = "https://avatars.githubusercontent.com/u/\(userId)?v=4"
            let userHtmlUrl: String = "https://github.com/\(username)"
            let userRepoUrl: String = "https://api.github.com/users/\(username)/repos"
            let userFullName: String = "Mojombo Real Name"
            let followers: Int = 9
            let following: Int = 3
            let url = URL(string: "\(sut.baseURL)/users/\(username)")!
            
            let responseJson = """
            {
                "login": "\(username)",
                "id": \(userId),
                "avatar_url": "\(avatar)",
                "url": "https://api.github.com/users/\(username)",
                "html_url": "\(userHtmlUrl)",
                "repos_url": "\(userRepoUrl)",
                "type": "User",
                "name": "\(userFullName)",
                "public_repos": 9,
                "public_gists": 0,
                "followers": \(followers),
                "following": \(following)
            }
            """
            
            let responseData = responseJson.data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            MockURLProtocol.mockResponses[url] = (data: responseData, response: response, error: nil)
            
            let result = try await sut.fetchUser(username)
            await expect(result.login).toEventually(equal(username))
            await expect(result.id).toEventually(equal(userId))
            await expect(result.avatarUrl).toEventually(equal(avatar))
            await expect(result.reposUrl).toEventually(equal(userRepoUrl))
            await expect(result.name).toEventually(equal(userFullName))
            await expect(result.followers).toEventually(equal(followers))
            await expect(result.following).toEventually(equal(following))
          }
        }
        
        context("when the request is failed") {
          it("should throw correct error") {
            let username: String = "mojombo"
            let url = URL(string: "\(sut.baseURL)/users/\(username)")!
            MockURLProtocol.mockResponses[url] = (data: nil, response: nil, error: HTTPError.noNetwork)
            
            await expecta(try await sut.fetchUser(username)).to(throwError(HTTPError.noNetwork))
          }
        }
      }
      
      describe("fetchUserList") {
        context("when the request is successful") {
          var username1: String!
          var userId1: Int!
          var avatar1: String!
          var userHtmlUrl1: String!
          var userRepoUrl1: String!
          var userFullName1: String!
          var followers1: Int!
          var following1: Int!
          
          var username2: String!
          var userId2: Int!
          var avatar2: String!
          var userHtmlUrl2: String!
          var userRepoUrl2: String!
          var userFullName2: String!
          var followers2: Int!
          var following2: Int!
          
          var responseJson: String!
          var nextUrlString: String!
          var lastUrlString: String!
          var firstUrlString: String!
          
          var url: URL!
          var responseHeader: [String: String]!
          
          beforeEach {
            username1 = "mojombo"
            userId1 = 1
            avatar1 = "https://avatars.githubusercontent.com/u/\(userId1!)?v=4"
            userHtmlUrl1 = "https://github.com/\(username1!)"
            userRepoUrl1 = "https://api.github.com/users/\(username1!)/repos"
            userFullName1 = "Mojombo Real Name"
            followers1 = 9
            following1 = 3
            
            username2 = "pjhyett"
            userId2 = 3
            avatar2 = "https://avatars.githubusercontent.com/u/\(userId2!)?v=4"
            userHtmlUrl2 = "https://github.com/\(username2!)"
            userRepoUrl2 = "https://api.github.com/users/\(username2!)/repos"
            userFullName2 = "pjhyett Real Name"
            followers2 = 9
            following2 = 3
            
            responseJson = """
            [{
                "login": "\(username1!)",
                "id": \(userId1!),
                "avatar_url": "\(avatar1!)",
                "url": "https://api.github.com/users/\(username1!)",
                "html_url": "\(userHtmlUrl1!)",
                "repos_url": "\(userRepoUrl1!)",
                "type": "User",
                "name": "\(userFullName1!)",
                "public_repos": 9,
                "public_gists": 0,
                "followers": \(followers1!),
                "following": \(following1!)
            },
            {
                "login": "\(username2!)",
                "id": \(userId2!),
                "avatar_url": "\(avatar2!)",
                "url": "https://api.github.com/users/\(username2!)",
                "html_url": "\(userHtmlUrl2!)",
                "repos_url": "\(userRepoUrl2!)",
                "type": "User",
                "name": "\(userFullName2!)",
                "public_repos": 9,
                "public_gists": 0,
                "followers": \(followers2!),
                "following": \(following2!)
            }]
            """
            
            nextUrlString = "\(sut.baseURL)/users?since=50"
            lastUrlString = "\(sut.baseURL)/users?since=200"
            firstUrlString = "\(sut.baseURL)/users{?since}"
            
            url = URL(string: "\(sut.baseURL)/users?per_page=30")!
            
            responseHeader = [
              "Link": """
                <\(nextUrlString!)>; rel="next", <\(firstUrlString!)>; rel="first, <\(lastUrlString!)>; rel="last"
              """
            ]
          }
          
          it("should return correct GitHubUser array for initial fetch") {
            let responseData = responseJson.data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: responseHeader)
            MockURLProtocol.reset()
            
            MockURLProtocol.mockResponses[url] = (data: responseData, response: response, error: nil)
            
            let result = try await sut.fetchUserList()
            expect(result.results?.count).to(equal(2))
            expect(result.hasNext).to(beTrue())
            expect(result.hasLast).to(beTrue())
            expect(result.hasPrevious).to(beFalse())
            expect(result.first).toNot(beNil())
            expect(result.next).toNot(beNil())
            expect(result.last).toNot(beNil())
            expect(result.previous).to(beEmpty())
            
            if let list = result.results, list.count > 1 {
              expect(list[0].id).to(equal(userId1))
              expect(list[0].login).to(equal(username1))
              expect(list[0].name).to(equal(userFullName1))
              expect(list[0].avatarUrl).to(equal(avatar1))
              expect(list[0].reposUrl).to(equal(userRepoUrl1))
              expect(list[0].followers).to(equal(followers1))
              expect(list[0].following).to(equal(following1))
              
              expect(list[1].id).to(equal(userId2))
              expect(list[1].login).to(equal(username2))
              expect(list[1].name).to(equal(userFullName2))
              expect(list[1].avatarUrl).to(equal(avatar2))
              expect(list[1].reposUrl).to(equal(userRepoUrl2))
              expect(list[1].followers).to(equal(followers2))
              expect(list[1].following).to(equal(following2))
            }
            
          }
          
          it("should return correct GitHubUser array for the next fetch") {
            let currentLink = responseHeader["Link"] ?? ""
            let headerLink = HTTPResponseHeaderLink(rawValue: currentLink)
            let pagedObject: PagedObject<GitHubUser> = PagedObject(
              from: headerLink,
              with: .initial(pageLimit: 30),
              currentUrl: url.absoluteString,
              results: [])
            
            // create new URL using the current's next
            url = URL(string: "\(nextUrlString!)&per_page=30")!
            
            // we modified nextUrlString and responseHeader for the subsequent fetch
            nextUrlString = "\(sut.baseURL)/users?since=100"
            responseHeader = [
              "Link": """
                <\(nextUrlString!)>; rel="next", <\(firstUrlString!)>; rel="first, <\(lastUrlString!)>; rel="last"
              """
            ]
            
            let responseData = responseJson.data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: responseHeader)
            MockURLProtocol.reset()
            
            MockURLProtocol.mockResponses[url] = (data: responseData, response: response, error: nil)
            
            let result = try await sut.fetchUserList(paginationState: .continuing(pagedObject, .next))
            
            expect(result.results?.count).to(equal(2))
            expect(result.hasNext).to(beTrue())
            expect(result.hasLast).to(beTrue())
            expect(result.hasPrevious).to(beFalse())
            expect(result.first).toNot(beNil())
            expect(result.next).toNot(beNil())
            expect(result.last).toNot(beNil())
            expect(result.previous).to(beEmpty())
            
            if let list = result.results, list.count > 1 {
              expect(list[0].id).to(equal(userId1))
              expect(list[0].login).to(equal(username1))
              expect(list[0].name).to(equal(userFullName1))
              expect(list[0].avatarUrl).to(equal(avatar1))
              expect(list[0].reposUrl).to(equal(userRepoUrl1))
              expect(list[0].followers).to(equal(followers1))
              expect(list[0].following).to(equal(following1))
              
              expect(list[1].id).to(equal(userId2))
              expect(list[1].login).to(equal(username2))
              expect(list[1].name).to(equal(userFullName2))
              expect(list[1].avatarUrl).to(equal(avatar2))
              expect(list[1].reposUrl).to(equal(userRepoUrl2))
              expect(list[1].followers).to(equal(followers2))
              expect(list[1].following).to(equal(following2))
            }
          }
        }
        
        context("when the request is failed") {
          var url: URL!
          
          beforeEach {
            url = URL(string: "\(sut.baseURL)/users?per_page=30")!
          }
          
          it("should throw correct error") {
            MockURLProtocol.mockResponses[url] = (data: nil, response: nil, error: HTTPError.noNetwork)
            
            await expecta(try await sut.fetchUserList()).to(throwError(HTTPError.noNetwork))
          }
        }
      }
    }
  }
}
// swiftlint:enable type_body_length
// swiftlint:enable function_body_length
