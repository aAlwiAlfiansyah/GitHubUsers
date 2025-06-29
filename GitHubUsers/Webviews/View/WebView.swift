//
//  WebView.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 29/06/25.
//

import SwiftUI
import WebKit

struct WebView: View {
  var url: String

  var body: some View {
    VStack {
      WebViewRepresentable(URL(string: url)!)
    }
  }
}

struct WebViewRepresentable: UIViewRepresentable {
  let url: URL
  
  init(_ url: URL) {
    self.url = url
  }
  
  func makeUIView(context: Context) -> some UIView {
    let webView = WKWebView()
    webView.load(URLRequest(url: url))
    
    return webView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#Preview {
  let url: String = "https://medium.com/@jpmtech"
  return WebView(url: url)
}
