import SwiftUI
import FirebaseCore

@main
struct Party_AppApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  @StateObject private var authManager = AuthManager()
  @StateObject private var authViewModel = AuthViewModel()
  @StateObject private var locationManager = LocationManager()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authManager)
        .environmentObject(authViewModel)
        .environmentObject(locationManager)
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure(); return true
  }
}
