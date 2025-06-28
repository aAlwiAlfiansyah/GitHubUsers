//
//  Decodable+Decode.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation


extension Decodable {
  public static func decode(from data: Data) throws -> Self {
    return try JSONDecoder().decode(self, from: data)
  }
}


extension Array where Element: Decodable {
  public static func decode(from data: Data) throws -> Array {
    return try JSONDecoder().decode(self, from: data)
  }
}
