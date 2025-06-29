//
//  StringExtensionsTests.swift
//  GitHubUsersTests
//
//  Created by Alwi Alfiansyah Ramdan on 30/06/25.
//

import XCTest

import Quick
import Nimble
@testable import GitHubUsers

final class StringExtensionsTests: QuickSpec {

  override class func spec(){
    describe("String Class") {
      describe("deletingPrefix") {
        it("should return the correct value") {
          
          expect("".deletingPrefix("dogI")).to(equal(""))
          expect("dogImage.dogBreed".deletingPrefix("dogI")).to(equal("mage.dogBreed"))
          expect("dogImage.dogBreed".deletingPrefix("mamamia")).to(equal("dogImage.dogBreed"))
        }
      }
    }
  }

}
