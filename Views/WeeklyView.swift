import SwiftUI

struct WeeklyView: View {
   var body: some View {
      ZStack {
         Color.orange.edgesIgnoringSafeArea(.all)
         Text("Weekly")
            .font(.system(size: 80, weight: .bold, design: .default))
            .foregroundStyle(.white)
      }
   }
}

#Preview {
    WeeklyView()
}
