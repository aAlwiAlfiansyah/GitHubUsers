//
//  HTTPHeader.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation


public enum HTTPHeader {
    case contentType(MediaType)
    case accept(MediaType)
    case acceptVersion(String)
    case ifModifiedSince(Date)
    
    public var key: String {
        switch self {
        case .contentType:
            return "Content-Type"
        case .accept, .acceptVersion:
            return "Accept"
        case .ifModifiedSince:
            return "If-Modified-Since"
        }
    }
    
    public var value: String {
        switch self {
        case .contentType(let mediaType):
            return mediaType.headerValue
        case .accept(let mediaType):
            return mediaType.headerValue
        case .acceptVersion(let value):
            return value
        case .ifModifiedSince(let date):
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
            return dateFormatter.string(from: date)
        }
    }
}

public enum HTTPResponseHeader {
  case link
  case rateLimitRemaining
  case rateLimitReset
  
  public static func key(headerType: HTTPResponseHeader) -> String {
    switch headerType {
    case .link:
      return "Link"
    case .rateLimitRemaining:
      return "X-RateLimit-Remaining"
    case .rateLimitReset:
      return "X-RateLimit-Reset"
    }
  }
}

public struct HTTPResponseHeaderLink {
  public let rawValue: String
  
  var linksMap: [String: String]
  
  public init(rawValue: String) {
    self.rawValue = rawValue
    self.linksMap = [:]
    
    generateMap()
  }
  
  mutating func generateMap() {
    if linksMap.isEmpty {
      let headersArray = rawValue.components(separatedBy: ",")
      
      for theHeader in headersArray {
        let url = theHeader.components(separatedBy: ";")[0].trimmingCharacters(in: .whitespacesAndNewlines).deletingPrefix("<").deletingSuffix(">")
        if let firstMatch = try? /.+rel="(.+)"/.firstMatch(in: theHeader), firstMatch.1.count > 0 {
          linksMap[String(firstMatch.1)] = url
        }
      }
    }
  }
  
  private func retrieveLinkValue(key: String) -> String {
    if let value = linksMap[key] {
      return value
    }
        
    return ""
  }
  
  public func retrieveFirstLink() -> String {
    return retrieveLinkValue(key: "first")
  }
  
  public func retrieveLastLink() -> String {
    return retrieveLinkValue(key: "last")
  }
  
  public func retrieveNextLink() -> String {
    return retrieveLinkValue(key: "next")
  }
  
  public func retrievePrevLink() -> String {
    return retrieveLinkValue(key: "prev")
  }
}



public struct MediaType: OptionSet, Sendable {
    public let rawValue: Int
    
    public static let json = MediaType(rawValue: 1 << 0)
    public static let html = MediaType(rawValue: 1 << 1)
    public static let plainText = MediaType(rawValue: 1 << 2)
    public static let png = MediaType(rawValue: 1 << 3)
    public static let jpeg = MediaType(rawValue: 1 << 4)
    public static let form = MediaType(rawValue: 1 << 5)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    
    /// The format required for the HTTP header
    public var headerValue: String {
        var values = [String]()
        
        if self.contains(.json) {
            values.append("application/json")
        }
        
        if self.contains(.html) {
            values.append("text/html")
        }
        
        if self.contains(.plainText) {
            values.append("text/plain")
        }
        
        if self.contains(.png) {
            values.append("image/png")
        }
        
        if self.contains(.jpeg) {
            values.append("image/jpeg")
        }
        
        if self.contains(.form) {
            values.append("application/x-www-form-urlencoded")
        }
        
        return values.joined(separator: "; ")
    }
}



// Taken from https://stackoverflow.com/a/32103136 - Chris 2/7/18
public extension OptionSet where RawValue: FixedWidthInteger {
    func elements() -> AnySequence<Self> {
        var remainingBits = rawValue
        var bitMask: RawValue = 1
        return AnySequence {
            return AnyIterator {
                while remainingBits != 0 {
                    defer { bitMask = bitMask &* 2 }
                    if remainingBits & bitMask != 0 {
                        remainingBits = remainingBits & ~bitMask
                        return Self(rawValue: bitMask)
                    }
                }
                return nil
            }
        }
    }
}
