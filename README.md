# 📦 GitHubUsers
A simple and clean SwiftUI-based iOS application to browse GitHub users and GitHub user's repositories. 

---

## 🚀 Features
- The app will show the first 30 GitHub users, containing the user avatar and username
- Upon scrolling to the bottom, the app will fetch and append the next 30 GitHub users into the list
- Search feature with pagination for GitHub users by GitHub username in the GitHub Users Search page
- Upon clicking the GitHub user in the list, it will show the GitHub user details page
- The GitHub user details page will show the user avatar, username, full name, number of followers, and number of following
  - At the bottom of the GitHub user details information, the app will show the first 30 user's GitHub repositories
  - The item in user's GitHub repositories list will show the repository name, its programming language, the number of stargazers and the repository description if any
  - Upon scrolling to the bottom of the user's GitHub repositories list, the app will fetch and append the next 30 GitHub user's repositories into the list
  - Search feature for GitHub featched repositories list in the GitHub user details page
- Upon clicking the GitHub user details information, the app will open webview to the user GitHub webpage
- Upon clicking one of the repository in the user's GitHub repositories list, the app will open webview to the repository GitHub webpage
- Smooth and responsive UI with loading indicators and error handling.

---

## 🧰 Tech Stack

- **Platform**: iOS
- **Language**: Swift
- **Architecture**: MVVM (Model-View-ViewModel)
- **UI**: SwiftUI
- **Networking**: URLSession
- **Dependency Management**: Swift Package Manager for in-app dependencies and Bundler and CocoaPods for secret file generator and GitHub workflow pipelines
- **Linters**: Swiftlint
- **CI/CD Pipelines**: GitHub Workflow Actions for linting using Swiftlint, Testing and Building the project using xcodebuild

---

## 📂 Project Structure
```
GitHubUsers/
├── Helpers # Helper classes and files (including generated files and their templates)
├── Utilities # General classes extensions
├── Network # Networks specific classes
├── Models # General model classes
├── Services # Service classes to interact with external APIs
├── GitHubUserList # Group that represents the User List page
    ├── ViewModel # Business logic and state management for User List page
    └── View # Screens and UI components
├── GitHubUserDetails # Group that represents the User Details page
    ├── ViewModel # Business logic and state management for User Details page
    └── View # Screens and UI components
└── Webviews
    └── View # Screens and UI components for webviews

GitHubUsersTests/
├── MockedServices # List of mocked classes from Services and Networks components
├── Utilities # List of unit tests classes for Utilities components
├── ViewModel # List of unit tests classes for ViewModel components
└── Services # List of unit tests classes for Services and Network components

GitHubUsersUITests/ # UI tests for the project

Resources/ # Other resources
```
---

## 🚀 Getting Started

### Prerequisites

- Xcode 15.1 or later
- iOS 17.1+ simulators or devices
- SwiftUI Support
- Ruby 2.7.5
- Bundle 2.1.4

### Installation

1. Clone this repository:
```bash
git clone https://github.com/aAlwiAlfiansyah/GitHubUsers.git
cd GitHubUsers
```

2. Prepare your GitHub Personal Access Token. You can follow [this instructions](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic) to create your own GitHub Personal Access Token.


3. Prepare env-vars.sh:
```bash
cp env-vars.sh.template env-vars.sh
chmod +x env-vars.sh
```

3. Update `GITHUB_ACCESS_TOKEN` ENV variable value in env-vars.sh to your GitHub Personal Access Token.

4. Install gems and cocoapods dependencies:
```bash
bundle install
bundle exec pod install
```

5. Open the workspace in Xcode:
```bash
open GitHubUsers.xcworkspace
```

### ▶️ Run in Simulator

1. Go to the repository directory:
```bash
cd GitHubUsers
```

2. Install gems and cocoapods dependencies:
```bash
bundle install
bundle exec pod install
```

3. Open the workspace in Xcode:
```bash
open GitHubUsers.xcworkspace
```

4. Select a simulator (e.g. iPhone 17.1)

5. Click **Run** ▶️ or press **Cmd + R**


### 📲 Run on Real Device

1. Plug in your iPhone/iPad to your MacOS device

2. Go to the repository directory:
```bash
cd GitHubUsers
```

3. Install gems and cocoapods dependencies:
```bash
bundle install
bundle exec pod install
```

4. Open the workspace in Xcode:
```bash
open GitHubUsers.xcworkspace
```

5. Select your device in the Xcode target bar

6. Make sure your Apple Developer Account is configured in Xcode (Preferences → Accounts)

7. Click **Run** ▶️


### 🧪 Testing

1. Go to the repository directory:
```bash
cd GitHubUsers
```

2. Install gems and cocoapods dependencies:
```bash
bundle install
bundle exec pod install
```

3. Open the workspace in Xcode:
```bash
open GitHubUsers.xcworkspace
```

4. Select a simulator for device target (e.g. iPhone 17.1)

5. Run tests via the **Product → Test** menu or press **Cmd + U**



---

## 🚀 Screen Recording
Here's a demo of the app in action:

<details>

<summary>Click to show/hide a demo GIF</summary>

![Demo](Resources/GitHubUsers_Demo.gif)

</details>

<details>

<summary>Click to show/hide a GitHub User Search feature Demo</summary>

![Demo](Resources/GitHubUsers_User_Search.gif)

</details>

<details>

<summary>Click to show/hide a GitHub Repo Search and Webview feature Demo in User Details page</summary>

![Demo](Resources/GitHubUsers_Repo_Search_User_Details.gif)

</details>

---
