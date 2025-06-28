//
//  URLResponse+.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation


extension HTTPURLResponse {
  public var httpStatus: HTTPStatus {
    return HTTPStatus(code: self.statusCode)
  }
  
  public var httpResponseHeaderLink: HTTPResponseHeaderLink? {

    if let linkHeader: String = self.allHeaderFields[HTTPResponseHeader.key(headerType: .link)] as? String {
      return HTTPResponseHeaderLink(rawValue: linkHeader)
    }
    
    return nil
  }
}
