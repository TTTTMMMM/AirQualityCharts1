import SwiftUI

struct ContentView: View {
   let clvmArray: [ChartListViewModel]

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
            .styleList()
         }
         .styleNavStack()
      }
      .background(Color.accentColor.opacity(0.6))
   }
}

#Preview {
   let clvmArray: [ChartListViewModel] = clvmArray
   ContentView(clvmArray: clvmArray)
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
