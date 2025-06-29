//
//  GitHubUsersApp.swift
//  GitHubUsers
//
//  Created by Alwi Alfiansyah Ramdan on 28/06/25.
//

import SwiftUI
import SwiftData

@main
struct GitHubUsersApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            let githubUserAPI = GitHubUsersAPI()
            let viewModel = GitHubUserListViewModel(githubUsersAPI: githubUserAPI)
            GitHubUserListView(viewModel: viewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
