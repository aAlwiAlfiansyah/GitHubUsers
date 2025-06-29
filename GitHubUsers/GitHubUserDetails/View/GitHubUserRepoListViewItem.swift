//
//  GitHubUserRepoListViewItem.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 29/06/25.
//

import SwiftUI

struct GitHubUserRepoListViewItem: View {
  let githubRepo: GitHubRepo
  
  var body: some View {
    VStack {
      if let name = githubRepo.name {
        Text(name)
          .font(.system(size: 20, weight: .bold, design: .monospaced))
          .foregroundStyle(.black)
          .lineLimit(1)
          .allowsTightening(true)
          .minimumScaleFactor(0.5)
      }
      
      HStack(alignment: .bottom) {
        
        if let language = githubRepo.language {
          Text(language)
            .font(.system(size: 18, weight: .regular, design: .monospaced))
            .italic()
            .foregroundStyle(.black)
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(0.5)
            
        }
        
        if let stargazersCount = githubRepo.stargazersCount {
          Label {
            Text("(\(stargazersCount))")
              .font(.system(size: 15, weight: .regular, design: .monospaced))
              .foregroundStyle(.black)
              .lineLimit(1)
              .allowsTightening(true)
              .minimumScaleFactor(0.5)
          } icon: {
            Image(systemName: "star.fill")
          }
        }
      }
      .padding(.top, 5)
      .padding(.bottom, 15)
      
      if let description = githubRepo.description {
        Text(description)
          .font(.system(size: 15, weight: .regular, design: .monospaced))
          .italic()
          .foregroundStyle(.black)
          .lineLimit(3)
          .allowsTightening(false)
          .minimumScaleFactor(0.8)
          .padding(.bottom, 15)
          .padding(.top, 5)
      }
      
      Line()
        .stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
        .frame(height: 1)
//        .padding(.vertical)
      
    }
    .padding()
  }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

#Preview {
  let repo = GitHubRepo(
    id: 26899533,
    name: "cocoapods-binary",
    description: "integrate pods in form of prebuilt frameworks conveniently, reducing compile time",
    fork: false,
    htmlUrl: "https://github.com/aAlwiAlfiansyah/cocoapods-binary",
    language: "Ruby",
    stargazersCount: 12
  )
  return GitHubUserRepoListViewItem(githubRepo: repo)
}
