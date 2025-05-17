import SwiftUI
import FirebaseCore
import FirebaseFirestore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct AirQualityChartsApp: App {
   
   // register app delegate for Firebase setup
   @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

   let clvmArrayInitial: [ChartListViewModel] = clvmArray
    var body: some Scene {
        WindowGroup {
           RootView()
//            ContentView(clvmArray: clvmArrayInitial)
        }
    }
}
