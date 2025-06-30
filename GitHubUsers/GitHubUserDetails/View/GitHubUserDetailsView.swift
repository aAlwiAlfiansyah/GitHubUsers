//
//  GitHubUserDetailsView.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 29/06/25.
//

import SwiftUI

struct GitHubUserDetailsView: View {
  @ObservedObject var viewModel: GitHubUserDetailsViewModel
  
  // Coordinate space for repo list scroll view
  private let COORDINATE_SPACE: String = "InfiniteReposListScrollContainer"
  
  // Bottom offset for loading indicator
  @State private var bottomOffset: CGFloat?
  // View height of loading indicator
  @State private var loadMoreViewHeight: CGFloat?
  // Lock for loading to prevent multiple calls
  @State private var loading: Bool = false
  
  // Scroll position item id
  @State var dataID: Int?
  
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
          .padding(.bottom, 25)
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
        .padding()
        .scrollTargetLayout()
        .padding(.bottom, loadMoreViewHeight)
        .background {
          // Geometry reader to calculate current scroll view offset
          // and call onScroll private function
          GeometryReader { proxy -> Color in
            onScroll(proxy: proxy)
            return Color.clear
          }
        }
      }
      .scrollPosition(id: $dataID)
      .coordinateSpace(name: COORDINATE_SPACE)
      .overlay(alignment: .bottom) {
        // Loading indicator
        // only visible if it's loading and there are something more to be fetched
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle())
          .scaleEffect(1.5)
          .padding()
          .tint(.black)
          .readGeometry {
            if loadMoreViewHeight != $0.height {
              loadMoreViewHeight = $0.height
            }
          }
          .offset(y: bottomOffset ?? 1000)
          .opacity(loading && viewModel.hasNext ? 1 : 0)
          
      }
      .onChange(of: viewModel.githubRepos.count) { oldValue, newValue in
        if newValue < oldValue {
          // if newValue is less than oldValue, the list is empty
          // we need to refetch the user list
          Task {
            await viewModel.fetchInitialGitHubUserRepoList()
            dataID = viewModel.githubRepos.first?.id
          }
        } else if loading {
          // if newValue is more than oldValue, and it's loading, the list has new items
          // we need to set the loading to false
          // add sleep to make sure there is no other process
          Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000)
            loading = false
          }
        }
      }
      
      Spacer()
    }
    .navigationTitle("GitHub User Details")
    .navigationBarTitleDisplayMode(.inline)
    .navigationDestination(for: GitHubRepo.self) { repo in
      
      if let repoHtml = repo.htmlUrl {
        WebView(url: repoHtml)
      }
    }
    .onAppear {
      Task {
        await viewModel.fetchUserDetailsInfo()
        
        // Only reloading github user repo list if current list is empty
        if viewModel.githubRepos.isEmpty {
          await viewModel.fetchInitialGitHubUserRepoList()
          dataID = viewModel.githubRepos.first?.id
        }
      }
    }
  }
  
  // Private function for detecting scroll position for infinite scroll.
  // Will call async function to fetch more if scroll position is at the bottom
  private func onScroll(proxy: GeometryProxy) {
    guard let bound = proxy.bounds(of: .named(COORDINATE_SPACE)) else { return }

    let topOffset = bound.minY
    let contentHeight = proxy.frame(in: .global).height
    let bottomOffset = contentHeight - bound.maxY
    
    Task { @MainActor in
      if self.bottomOffset != bottomOffset {
        self.bottomOffset = bottomOffset
      }
      
      if loading { return }
      
      if !viewModel.hasNext {
        loading = false
        return
      }
      
      // Currently, it's hard-coded to 0.8
      if let loadMoreViewHeight {
        if bottomOffset <= loadMoreViewHeight * 0.8 && topOffset >= 0 {
          loading = true
          await viewModel.fetchMoreGitHubUserRepoList()
        }
      }
    }
  }
}

#Preview {
  let githubUserAPI = GitHubUsersAPI()
  let githubUser: GitHubUser = GitHubUser(
    id: 4660283,
    login: "mojombo",
    name: "Alwi Alfiansyah Ramdan",
    avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
    reposUrl: "https://api.github.com/users/mojombo/repos",
    type: "User",
    followers: 56,
    following: 12
  )
  let viewModel = GitHubUserDetailsViewModel(githubUser: githubUser, gitHubUsersAPI: githubUserAPI)
  return GitHubUserDetailsView(viewModel: viewModel)
}
