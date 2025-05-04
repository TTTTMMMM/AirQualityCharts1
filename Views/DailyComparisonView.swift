import SwiftUI

struct DailyComparisonView: View {
   var body: some View {
      ZStack {
         Color.purple.edgesIgnoringSafeArea(.all)
         Text("Daily Comparison")
            .font(.system(size: 80, weight: .bold, design: .default))
            .foregroundStyle(.white)
      }
      
   }
}

#Preview {
    DailyComparisonView()
}
