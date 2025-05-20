import SwiftUI

struct RootView: View {
   
   @State private var showSignInView: Bool = false
   let clvmArrayInitial: [ChartListViewModel] = clvmArray
   
    var body: some View {
       ZStack {
          if !showSignInView {
             NavigationStack {
//                ProfileView(showSignInView: $showSignInView)
                ContentView(clvmArray: clvmArrayInitial, showSignInView: $showSignInView)
             }
          }
       }
       .onAppear {
          let authuser = try? AuthenticationManager.shared.getAuthenticatedUser()
          print(authuser as Any)
          self.showSignInView = authuser == nil
       }
       .fullScreenCover(isPresented: $showSignInView) {
          NavigationStack {
             AuthenticationView(showSignInView: $showSignInView)
          }
       }
    }
}

#Preview {
    RootView()
}
