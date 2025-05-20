import SwiftUI

struct ContentView: View {
   let clvmArray: [ChartListViewModel]
   @StateObject private var viewModel = ProfileViewModel()
   @Binding var showSignInView: Bool

   var body: some View {
      ZStack {
         NavigationStack() {
            List {
               ForEach (clvmArray) {item in
                  NavigationLink(destination: item.chartView) {
                     ListelementStyleView(nameOfImage: item.imageName, textToDisplayOnListElement: item.listDisplayText)
                  }
               }
               .styleListElement()
            }
            .onAppear() {
               try? viewModel.loadCurrentUser()
            }
            .styleList()
            .toolbar {
               ToolbarItem(placement: .navigationBarTrailing) {
                  NavigationLink {
                     SettingsView(showSignInView: $showSignInView)
                  } label: {
                     if let user = viewModel.user {
                        if let photoURL = user.photoURL {
                           AsyncImage(url: URL(string: photoURL)){ image in
                              image.resizable()
                           } placeholder: {
                              Color.accentColor
                           }
                           .frame(width: 30, height: 30)
                           .clipShape(.rect(cornerRadius: 25))
                        }
                     } else {
                        Image(systemName: "gear")
                           .font(.headline  )
                     }
                  }
               }
            }
         }
         .styleNavStack()
      }
      .background(Color.accentColor.opacity(0.6))
   }
}

#Preview {
   let clvmArray: [ChartListViewModel] = clvmArray
   ContentView(clvmArray: clvmArray, showSignInView: .constant(false))
}


extension View
{
   func styleList() -> some View {
      self
         .cornerRadius(15)
         .shadow(color: Color.black.opacity(0.5), radius: 5)
         .navigationTitle("Pick a Chart Type")
         .font(.system(size: 20, weight: .semibold, design: .rounded))
         .padding(10)
   }
}

extension View
{
   func styleListElement() -> some View {
      self
         .cornerRadius(15)
         .padding(1)
   }
}

extension View
{
   func styleNavStack() -> some View {
      self
         .cornerRadius(15)
         .shadow(color: Color.black.opacity(0.5), radius: 5)
         .padding(40)
   }
}
