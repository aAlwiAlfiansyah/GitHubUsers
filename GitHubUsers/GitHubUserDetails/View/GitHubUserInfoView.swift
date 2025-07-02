//
//  GitHubUserInfoView.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 29/06/25.
//

import SwiftUI

struct GitHubUserInfoView: View {
  let githubUser: GitHubUser
  
  let avatarSize: Double = 150.0
  
  var body: some View {
    HStack {
      Spacer()
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
        .frame(width: avatarSize, height: avatarSize)
        
      } else {
        ProgressView()
          .clipShape(.rect(cornerRadius: 25))
          .frame(width: avatarSize, height: avatarSize)
      }
      
      Spacer(minLength: 30)
      
      VStack(alignment: .leading) {
        if let name = githubUser.login {
          Text("@\(name)")
            .font(.system(size: 20, weight: .bold, design: .monospaced))
            .foregroundStyle(.black)
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(0.5)
            .padding(.bottom, 5)
        }
        
        if let name = githubUser.name {
          Text(name)
            .font(.system(size: 20, weight: .regular, design: .monospaced))
            .foregroundStyle(.black)
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(0.5)
            .padding(.bottom, 15)
        }
        
        if let followers = githubUser.followers {
          Text("followers: \(followers)")
            .font(.system(size: 15, weight: .regular, design: .monospaced))
            .foregroundStyle(.black)
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(0.5)
            .padding(.bottom, 5)
        }
        
        if let following = githubUser.following {
          Text("following: \(following)")
            .font(.system(size: 15, weight: .regular, design: .monospaced))
            .foregroundStyle(.black)
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(0.5)
            .padding(.bottom, 15)
        }
      }
      
      Spacer()
    }
    .frame(minWidth: 0, maxWidth: .infinity)
    .padding(20)
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
  return GitHubUserInfoView(githubUser: githubUser)
}
