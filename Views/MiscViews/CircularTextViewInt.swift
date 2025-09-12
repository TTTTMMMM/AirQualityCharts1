import SwiftUI

struct CircularTextViewInt: View {
   var topText: String
   var intValue: Int
   var circleColor: Color
   
   var body: some View {
      VStack {
          Text(topText)
              .font(.headline)
          Text("\(intValue)")
            .font(.system(size: 60, weight: .bold, design: .default))
      }
      .padding(20)
      .background(
          Circle()
              .fill(circleColor.opacity(0.6))
              .stroke(Color.black, lineWidth: 4)
      )
  }
}

#Preview {
//   @Previewable @State var intValue = 176
   var intValue = 176
   var topText: String = "TVOC"
   var circleColor: Color = .red
   
   CircularTextViewInt(topText: topText, intValue: intValue, circleColor: circleColor)

}
