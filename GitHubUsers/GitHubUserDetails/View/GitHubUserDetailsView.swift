//
//  GitHubUserDetailsView.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 29/06/25.
//

import SwiftUI

struct GitHubUserDetailsView: View {
  @ObservedObject var viewModel: GitHubUserDetailsViewModel
  var body: some View {
    VStack {
      GitHubUserInfoView(githubUser: viewModel.githubUser)
        .frame(minWidth: 0, maxWidth: .infinity)
      
      VStack {
        Text("Repo List")
          .font(.system(size: 20, weight: .bold, design: .monospaced))
          .italic()
          .foregroundStyle(.black)
          .lineLimit(1)
          .allowsTightening(false)
          .minimumScaleFactor(0.5)
          .padding(.bottom, 15)
          .padding(.top, 25)
      }
      .frame(minWidth: 0, maxWidth: .infinity)
      .background(Color.gray.opacity(0.3))
      
      
      ScrollView {
        LazyVStack {
          ForEach(viewModel.githubRepos.compactMap { $0 }, id: \.id) { item in
            NavigationLink(value: item) {
              GitHubUserRepoListViewItem(githubRepo: item)
            }
          }
        }
      }
      Spacer()
    }
    .navigationTitle("GitLab User Details")
    .navigationBarTitleDisplayMode(.inline)
    .navigationDestination(for: GitHubRepo.self) { repo in
      
      if let repoHtml = repo.htmlUrl {
        WebView(url: repoHtml)
      }
    }
    .onAppear {
      Task {
        await viewModel.fetchUserDetailsInfo()
        await viewModel.fetchInitialGitHubUserRepoList()
      }
    }
  }
}

#Preview {
  let githubUserAPI = GitHubUsersAPI()
  let githubUser: GitHubUser = GitHubUser(
    id: 4660283,
    login: "aAlwiAlfiansyah",
    name: "Alwi Alfiansyah Ramdan",
    avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
    reposUrl: "https://api.github.com/users/aAlwiAlfiansyah/repos",
    type: "User",
    followers: 56,
    following: 12
  )
  let viewModel = GitHubUserDetailsViewModel(githubUser: githubUser, gitHubUsersAPI: githubUserAPI)
  return GitHubUserDetailsView(viewModel: viewModel)
}
