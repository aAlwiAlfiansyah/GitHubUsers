//
//  View+Extensions.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 29/06/25.
//

import SwiftUI

@available(iOS 14, macOS 11, *)
public extension View {
  /// Read the geometry of the view.
  func readGeometry(onChange: @escaping (CGSize) -> Void) -> some View {
    modifier(HuggingGeometryModifier {
      onChange($0)
    })
  }
}

@available(iOS 14, macOS 11, *)
internal struct HuggingGeometryModifier: ViewModifier {
  
  let onChange: (CGSize) -> Void
  
  func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { proxy in
          Color.clear.preference(key: SizeKey.self, value: proxy.size)
        }
      )
      .onPreferenceChange(SizeKey.self) {
        onChange($0)
      }
  }
  
  private struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize { CGSize() }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
  }
}
