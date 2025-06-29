# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'
install! 'cocoapods', :deterministic_uuids => false, :warn_for_unused_master_specs_repo => false

target 'GitHubUsers' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Sourcery', :subspecs => ['CLI-Only']

  # Pods for GitHubUsers
  target 'GitHubUsersTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GitHubUsersUITests' do
    # Pods for testing
  end

end
