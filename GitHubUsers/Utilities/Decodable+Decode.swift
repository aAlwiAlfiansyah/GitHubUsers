//
//  Decodable+Decode.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import Foundation


extension Decodable {
  public static func decode(from data: Data) throws -> Self {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(self, from: data)
  }
}


extension Array where Element: Decodable {
  public static func decode(from data: Data) throws -> Array {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(self, from: data)
  }
}
