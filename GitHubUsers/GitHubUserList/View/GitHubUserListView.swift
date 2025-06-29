//
//  GitHubUserListView.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import SwiftUI

struct GitHubUserListView: View {
  @ObservedObject var viewModel: GitHubUserListViewModel
  
  private static let initialColumns = 3
  private let COORDINATE_SPACE: String = "InfiniteScrollContainer"
  
  @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
  @State private var numColumns = initialColumns
  
  @State private var bottomOffset: CGFloat?
  @State private var loadMoreViewHeight: CGFloat?
  // Lock for loading to prevent multiple calls
  @State private var loading: Bool = false
  
  @State var dataID: Int?

  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: gridColumns) {
          ForEach(viewModel.githubUsers.compactMap { $0 }, id: \.id) { item in
            GeometryReader { geo in
              GitHubUserListViewItem(size: geo.size.width, githubUser: item)
            }
            .cornerRadius(8.0)
            .aspectRatio(0.7, contentMode: .fit)
            
          }
        }
        .padding()
        .scrollTargetLayout()
        .padding(.bottom, loadMoreViewHeight)
      }
      .scrollPosition(id: $dataID)
      .coordinateSpace(name: COORDINATE_SPACE)
    }
    .onAppear {
      Task {
        await viewModel.fetchInitialGitHubUserList()
      }
    }
  }
}

#Preview {
  let githubUserAPI = GitHubUsersAPI()
  let viewModel = GitHubUserListViewModel(githubUsersAPI: githubUserAPI)
  return GitHubUserListView(viewModel: viewModel)
}
