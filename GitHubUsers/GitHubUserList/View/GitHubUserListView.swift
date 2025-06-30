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
  
  // Coordinate space for list scroll view
  private let COORDINATE_SPACE: String = "InfiniteScrollContainer"
  
  @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
  @State private var numColumns = initialColumns
  
  // Bottom offset for loading indicator
  @State private var bottomOffset: CGFloat?
  // View height of loading indicator
  @State private var loadMoreViewHeight: CGFloat?
  // Lock for loading to prevent multiple calls
  @State private var loading: Bool = false
  
  // Scroll position item id
  @State var dataID: Int?
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: gridColumns) {
          ForEach(viewModel.githubUsers.compactMap { $0 }, id: \.id) { item in
            GeometryReader { geo in
              NavigationLink(value: item) {
                GitHubUserListViewItem(size: geo.size.width, githubUser: item)
              }
              
            }
            .cornerRadius(8.0)
            .aspectRatio(0.7, contentMode: .fit)
            
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
      .navigationTitle("GitLab User List")
      .navigationBarTitleDisplayMode(.inline)
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
      .onChange(of: viewModel.githubUsers.count) { oldValue, newValue in
        if newValue < oldValue {
          // if newValue is less than oldValue, the list is empty
          // we need to refetch the user list
          Task {
            await viewModel.fetchInitialGitHubUserList()
            dataID = viewModel.githubUsers.first?.id
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
      .navigationDestination(for: GitHubUser.self) { [weak viewModel] user in
        
        if let gitHubUsersAPI = viewModel?.gitHubUsersAPI {
          let viewModel = GitHubUserDetailsViewModel(
            githubUser: user,
            gitHubUsersAPI: gitHubUsersAPI)
          
          GitHubUserDetailsView(viewModel: viewModel)
        }
      }
    }
    .onAppear {
      Task {
        // Only reloading github user list if current list is empty
        if viewModel.githubUsers.isEmpty {
          await viewModel.fetchInitialGitHubUserList()
          dataID = viewModel.githubUsers.first?.id
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
      
      // Currently, it's hard-coded to 0.8
      if let loadMoreViewHeight {
        if bottomOffset <= loadMoreViewHeight * 0.8 && topOffset >= 0 {
          loading = true
          await viewModel.fetchMoreGitHubUserList()
        }
      }
    }
  }
}

#Preview {
  let githubUserAPI = GitHubUsersAPI()
  let viewModel = GitHubUserListViewModel(githubUsersAPI: githubUserAPI)
  return GitHubUserListView(viewModel: viewModel)
}
