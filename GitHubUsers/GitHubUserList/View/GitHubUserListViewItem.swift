//
//  GitHubUserListViewItem.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import SwiftUI

struct GitHubUserListViewItem: View {
  let size: Double
  let githubUser: GitHubUser
  
  var body: some View {
    VStack {
      if let avatarURL = githubUser.avatarUrl {
        let url = URL(string: avatarURL)!
        AsyncImage(url: url) { image in
          image
            .resizable()
            .scaledToFill()
            .clipShape(.rect(cornerRadius: 25))
        } placeholder: {
          ProgressView()
            .clipShape(.rect(cornerRadius: 25))
        }
        .padding()
        .frame(width: size, height: size)
        
      } else {
        ProgressView()
          .clipShape(.rect(cornerRadius: 25))
          .frame(width: size, height: size)
      }
      
      if let name = githubUser.login {
        Text(name)
          .font(.system(size: 18, weight: .bold, design: .monospaced))
          .foregroundStyle(.black)
          .lineLimit(1)
          .allowsTightening(true)
          .minimumScaleFactor(0.5)
          .padding(.bottom, 15)
      }
    }
    .frame(width: size, height: size / 0.8)
    .background(Color.gray.opacity(0.1))
    .clipShape(.rect(cornerRadius: 25))
  }
}

#Preview {
  let githubUser: GitHubUser = GitHubUser(
    id: 4660283,
    login: "aAlwiAlfiansyah",
    name: "Alwi Alfiansyah Ramdan",
    avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
    reposUrl: "https://api.github.com/users/aAlwiAlfiansyah/repos",
    htmlUrl: "https://github.com/aAlwiAlfiansyah",
    type: "User",
    followers: 56,
    following: 12
  )
  let size: Double = 150.0
  return GitHubUserListViewItem(size: size, githubUser: githubUser)
}
