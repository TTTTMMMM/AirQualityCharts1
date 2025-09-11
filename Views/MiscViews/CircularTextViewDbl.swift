import SwiftUI

struct CircularTextViewDbl: View {
   var topText: String
   var dblValue: Double
   var circleColor: Color
   
   var body: some View {
      VStack {
          Text(topText)
              .font(.headline)
          Text(String(format: "%.1f", dblValue))
            .font(.system(size: 60, weight: .bold, design: .default))
      }
      .padding(30)
      .background(
          Circle()
              .fill(circleColor.opacity(0.8))
              .stroke(Color.black, lineWidth: 4)
      )
  }
}

#Preview {
   var topText: String = "Temp"
   var dblValue: Double = 72.5
   var circleColor: Color = .green
   
   CircularTextViewDbl(topText: topText, dblValue: dblValue, circleColor: circleColor)

}
