import SwiftUI

struct CircularTextViewIntLarge: View {
   var metricType: MetricType
   var topText: String
   var intValue: Int
   var circleColor: Color
   var sizeOfText: CGFloat
   
   var body: some View {
      VStack {
         Text(topText)
         switch metricType {
            case .count:
               Text("\(intValue.formatted(.number.grouping(.never)))")
                  .font(.system(size: sizeOfText, weight: .bold, design: .default))
            default:
               Text("\(intValue.formatted(.number.grouping(.never)))°")
                  .font(.system(size: sizeOfText, weight: .bold, design: .default))
         }
      }
      .padding(21)
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
   var sizeOfText : CGFloat = 60
   
   CircularTextViewIntLarge(metricType: .count, topText: topText, intValue: intValue, circleColor: circleColor, sizeOfText: sizeOfText)

}
