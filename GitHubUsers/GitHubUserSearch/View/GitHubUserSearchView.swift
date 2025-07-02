//
//  GitHubUserSearchView.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 02/07/25.
//

import SwiftUI

struct GitHubUserSearchView: View {
  @ObservedObject var viewModel: GitHubUserSearchViewModel
  
  private static let initialColumns = 3
  
  @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
  @State private var numColumns = initialColumns
  
  @State private var searchTerm: String = ""
  
  // Scroll position item id
  @State var dataID: Int?
  
  var body: some View {
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
    }
    .scrollPosition(id: $dataID)
    .navigationTitle("GitHub User Search")
    .navigationBarTitleDisplayMode(.inline)
    .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search GitHub Username")
    .onSubmit(of: .search) {
      guard !searchTerm.isEmpty else {
        viewModel.resetGitHubUsers()
        return
      }
      
      Task {
        await viewModel.searchInitialGitHubUser(searchTerm)
      }
    }
    .toolbar {
      ToolbarItem(placement: .bottomBar) {
        Button {
          guard !searchTerm.isEmpty else {
            return
          }
          
          Task {
            await viewModel.fetchMoreGitHubUserSearch(searchTerm, .previous)
          }
          
        } label: {
          HStack(alignment: .bottom) {
            Image(systemName: "chevron.backward")
            Text("Prev")
          }
        }
        .disabled(!viewModel.hasPrev)
      }
      ToolbarItem(placement: .bottomBar) {
        Button {
          guard !searchTerm.isEmpty else {
            return
          }
          
          Task {
            await viewModel.fetchMoreGitHubUserSearch(searchTerm, .next)
          }
        } label: {
          HStack(alignment: .bottom) {
            Text("Next")
            Image(systemName: "chevron.forward")
          }
        }
        .disabled(!viewModel.hasNext)
      }
    }
  }
}

#Preview {
  let githubUserAPI = GitHubUsersAPI()
  let viewModel = GitHubUserSearchViewModel(githubUsersAPI: githubUserAPI)
  return GitHubUserSearchView(viewModel: viewModel)
}
