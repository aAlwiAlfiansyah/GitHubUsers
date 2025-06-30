//
//  URLSession+Request.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

extension URLSession {
  /**
   Starts the URLRequest and returns the response from the server or an error.
   
   - parameter request: The URLRequest
   - returns: Returns the web service response or throws an HTTPError
   */
  func startData(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    do {
      let (data, response) = try await self.data(for: request)
      
      if let response = response as? HTTPURLResponse {
        let status = HTTPStatus(code: response.statusCode)
        
        if status == .unauthorized {
          throw HTTPError.unauthorized
        } else if status.category == .success {
          return (data, response)
        } else {
          throw HTTPError.serverResponse(status, data)
        }
      } else {
        throw HTTPError.httpError
      }
    } catch {
      throw HTTPError.from(error)
    }
  }
}
