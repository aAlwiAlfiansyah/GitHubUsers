//
//  Pagination.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation

/// The state of a paginated web service call.
public enum PaginationState<T>: Sendable where T: Sendable {
  /// Required state the first time you call the paginated web service.
  case initial(pageLimit: Int)
  /// Used on subsequent calls to the paginated web service, getting results for that relationship.
  case continuing(PagedObject<T>, PaginationRelationship)
}

/// Public enum representing the different positions for pagination relative to the last fetch
public enum PaginationRelationship: Sendable {
  case first
  case last
  case next
  case previous
}

/// Paged Object
public struct PagedObject<T>: Codable, Sendable where T: Sendable {
  enum CodingKeys: String, CodingKey {
    case first
    case last
    case next
    case previous
  }
  
  /// The url for the first page in the list
  let first: String?
  
  /// The url for the last page in the list
  let last: String?
  
  /// The url for the next page in the list
  let next: String?
  
  /// The url for the previous page in the list
  let previous: String?
  
  /// The url for the current page
  let current: String
  
  /// The list of the objects
  var results: [T]?
  
  /// The number of results returned on each page
  public let limit: Int
  
  /// True if there are additional results that can be retrieved
  public var hasNext: Bool {
    guard let nextValue = next else {
      return false
    }
    
    return !nextValue.isEmpty
  }
  
  /// True if there are previous results that can be retrieved
  public var hasPrevious: Bool {
    guard let prevValue = previous else {
      return false
    }
    
    return !prevValue.isEmpty
  }
  
  /// True if there are results that can be retrieved in the last page
  public var hasLast: Bool {
    guard let lastValue = last else {
      return false
    }
    
    return !lastValue.isEmpty
  }
  
  // MARK: - Init
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.first = try container.decodeIfPresent(String.self, forKey: .first)
    self.last = try container.decodeIfPresent(String.self, forKey: .last)
    self.next = try container.decodeIfPresent(String.self, forKey: .next)
    self.previous = try container.decodeIfPresent(String.self, forKey: .previous)
    
    results = []
    limit = 0
    current = ""
  }
  
  public init(
    from headerLink: HTTPResponseHeaderLink?,
    with paginationState: PaginationState<T>,
    currentUrl: String,
    results: [T]) {
      
      if let headerLink = headerLink {
        first = headerLink.retrieveFirstLink()
        last = headerLink.retrieveLastLink()
        next = headerLink.retrieveNextLink()
        previous = headerLink.retrievePrevLink()
      } else {
        first = nil
        last = nil
        next = nil
        previous = nil
      }
      
      self.results = results
      
      switch paginationState {
      case .initial(let newLimit):
        limit = newLimit
      case .continuing(let pagedObject, _):
        limit = pagedObject.limit
      }
      
      current = currentUrl
    }
  
  /// Returns the url string of a current relationship if it exists
  public func getPageLink(for relationship: PaginationRelationship) -> String? {
    switch relationship {
    case .first:
      guard let url = self.first, url.count > 0 else {
        return nil
      }
      
      return url.replacingOccurrences(of: #"\{.*\}"#, with: "", options: .regularExpression, range: nil)
    case .last:
      return getLink(from: self.last)
    case .next:
      return getLink(from: self.next)
    case .previous:
      return getLink(from: self.previous)
    }
  }
  
  /// Helper function. Returns the url string if it exists, nil otherwise or the url is empty
  private func getLink(from urlString: String?) -> String? {
    guard let url = urlString, url.count > 0 else {
      return nil
    }
    
    return urlString
  }
}
