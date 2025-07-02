//
//  GitHubUserRepoServiceTests.swift
//  GitHubUsersTests
//
//  Created by Alwi Alfiansyah Ramdan on 02/07/25.
//

import XCTest
import Quick
import Nimble
@testable import GitHubUsers

// swiftlint:disable function_body_length
final class GitHubUserRepoServiceTests: AsyncSpec {
  override class func spec() {
    describe("GitHubUserRepoService") {
      var urlSession: URLSession!
      var sut: GitHubUserRepoService!
      
      beforeEach {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: config)
        sut = GitHubUserRepoService(session: urlSession)
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
      
      describe("fetchUserRepoList") {
        var username: String!
        
        var repoId1: Int!
        var repoName1: String!
        var repoHtmlUrl1: String!
        var repoDesc1: String!
        var repoIsFork1: Bool!
        var repoStarGazer1: Int!
        var repoLang1: String!
        
        var repoId2: Int!
        var repoName2: String!
        var repoHtmlUrl2: String!
        var repoDesc2: String!
        var repoIsFork2: Bool!
        var repoStarGazer2: Int!
        var repoLang2: String!
        
        var responseJson: String!
        var nextUrlString: String!
        var lastUrlString: String!
        var firstUrlString: String!
        
        var url: URL!
        var responseHeader: [String: String]!
        
        beforeEach {
          username = "takeo"
          repoId1 = 1340328
          repoName1 = "Brief"
          repoHtmlUrl1 = "https://github.com/\(username!)/\(repoName1!)"
          repoDesc1 = "Brief is a Chat Style for Skype 5 on OS X."
          repoIsFork1 = true
          repoStarGazer1 = 2
          repoLang1 = "Javascript"
          
          repoId2 = 494173
          repoName2 = "MooZoom"
          repoHtmlUrl2 = "https://github.com/\(username!)/\(repoName2!)"
          repoDesc2 = "An image zoomer for MooTools"
          repoIsFork2 = false
          repoStarGazer2 = 5
          repoLang2 = "Ruby"
        }
        
        context("when the request is successful") {
          beforeEach {
            responseJson = """
            [
              {
                "id": \(repoId1!),
                "name": "\(repoName1!)",
                "full_name": "\(username!)/\(repoName1!)",
                "private": false,
                "html_url": "\(repoHtmlUrl1!)",
                "description": "\(repoDesc1!)",
                "fork": \(repoIsFork1 ? "true" : "false"),
                "stargazers_count": \(repoStarGazer1!),
                "language": "\(repoLang1!)"
              },
              {
                "id": \(repoId2!),
                "name": "\(repoName2!)",
                "full_name": "\(username!)/\(repoName2!)",
                "private": false,
                "html_url": "\(repoHtmlUrl2!)",
                "description": "\(repoDesc2!)",
                "fork": \(repoIsFork2 ? "true" : "false"),
                "stargazers_count": \(repoStarGazer2!),
                "language": "\(repoLang2!)"
              },
            ]
            """
            
            nextUrlString = "\(sut.baseURL)/users/\(username!)/repos?since=50"
            lastUrlString = "\(sut.baseURL)/users/\(username!)/repos?since=200"
            firstUrlString = "\(sut.baseURL)/users/\(username!)/repos{?since}"
            
            url = URL(string: "\(sut.baseURL)/users/\(username!)/repos?per_page=30")!
            
            responseHeader = [
              "Link": """
                <\(nextUrlString!)>; rel="next", <\(firstUrlString!)>; rel="first, <\(lastUrlString!)>; rel="last"
              """
            ]
          }
          
          it("should return correct GitHubUserRepo array for initial fetch") {
            let responseData = responseJson.data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: responseHeader)
            MockURLProtocol.reset()
            
            MockURLProtocol.mockResponses[url] = (data: responseData, response: response, error: nil)
            
            let result = try await sut.fetchUserRepoList(username)
            expect(result.results?.count).to(equal(2))
            expect(result.hasNext).to(beTrue())
            expect(result.hasLast).to(beTrue())
            expect(result.hasPrevious).to(beFalse())
            expect(result.first).toNot(beNil())
            expect(result.next).toNot(beNil())
            expect(result.last).toNot(beNil())
            expect(result.previous).to(beEmpty())
            
            if let list = result.results, list.count > 1 {
              expect(list[0].id).to(equal(repoId1))
              expect(list[0].name).to(equal(repoName1))
              expect(list[0].htmlUrl).to(equal(repoHtmlUrl1))
              expect(list[0].description).to(equal(repoDesc1))
              expect(list[0].fork).to(equal(repoIsFork1))
              expect(list[0].stargazersCount).to(equal(repoStarGazer1))
              expect(list[0].language).to(equal(repoLang1))
              
              expect(list[1].id).to(equal(repoId2))
              expect(list[1].name).to(equal(repoName2))
              expect(list[1].htmlUrl).to(equal(repoHtmlUrl2))
              expect(list[1].description).to(equal(repoDesc2))
              expect(list[1].fork).to(equal(repoIsFork2))
              expect(list[1].stargazersCount).to(equal(repoStarGazer2))
              expect(list[1].language).to(equal(repoLang2))
            }
          }
          
          it("should return correct GitHubUserRepo array for the next fetch") {
            let currentLink = responseHeader["Link"] ?? ""
            let headerLink = HTTPResponseHeaderLink(rawValue: currentLink)
            let pagedObject: PagedObject<GitHubRepo> = PagedObject(
              from: headerLink,
              with: .initial(pageLimit: 30),
              currentUrl: url.absoluteString,
              results: [])
            
            // create new URL using the current's next
            url = URL(string: "\(nextUrlString!)&per_page=30")!
            
            // we modified nextUrlString and responseHeader for the subsequent fetch
            nextUrlString = "\(sut.baseURL)/users/\(username!)/repos?since=100"
            responseHeader = [
              "Link": """
                <\(nextUrlString!)>; rel="next", <\(firstUrlString!)>; rel="first, <\(lastUrlString!)>; rel="last"
              """
            ]
            
            let responseData = responseJson.data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: responseHeader)
            MockURLProtocol.reset()
            
            MockURLProtocol.mockResponses[url] = (data: responseData, response: response, error: nil)
            
            let result = try await sut.fetchUserRepoList(
              username,
              paginationState: .continuing(pagedObject, .next))
            expect(result.results?.count).to(equal(2))
            expect(result.hasNext).to(beTrue())
            expect(result.hasLast).to(beTrue())
            expect(result.hasPrevious).to(beFalse())
            expect(result.first).toNot(beNil())
            expect(result.next).toNot(beNil())
            expect(result.last).toNot(beNil())
            expect(result.previous).to(beEmpty())
            
            if let list = result.results, list.count > 1 {
              expect(list[0].id).to(equal(repoId1))
              expect(list[0].name).to(equal(repoName1))
              expect(list[0].htmlUrl).to(equal(repoHtmlUrl1))
              expect(list[0].description).to(equal(repoDesc1))
              expect(list[0].fork).to(equal(repoIsFork1))
              expect(list[0].stargazersCount).to(equal(repoStarGazer1))
              expect(list[0].language).to(equal(repoLang1))
              
              expect(list[1].id).to(equal(repoId2))
              expect(list[1].name).to(equal(repoName2))
              expect(list[1].htmlUrl).to(equal(repoHtmlUrl2))
              expect(list[1].description).to(equal(repoDesc2))
              expect(list[1].fork).to(equal(repoIsFork2))
              expect(list[1].stargazersCount).to(equal(repoStarGazer2))
              expect(list[1].language).to(equal(repoLang2))
            }
          }
        }
        
        context("when the request is failed") {
          it("should throw correct error") {
            url = URL(string: "\(sut.baseURL)/users/\(username!)/repos?per_page=30")!
            
            MockURLProtocol.mockResponses[url] = (data: nil, response: nil, error: HTTPError.noNetwork)
            
            await expecta(try await sut.fetchUserRepoList(username)).to(throwError(HTTPError.noNetwork))
          }
        }
      }
    }
  }
}
// swiftlint:enable function_body_length
