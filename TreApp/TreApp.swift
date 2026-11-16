import SwiftUI
import UIKit
import FirebaseCore

final class FirebaseAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TreApp: App {
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self)
    private var firebaseDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



#Preview {
    ContentView()
}
