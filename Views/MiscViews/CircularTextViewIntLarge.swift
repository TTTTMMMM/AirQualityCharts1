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
                  .font(.system(size: dynamicTextSize, weight: .bold, design: .default))
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
   
   private var dynamicTextSize: CGFloat {
      if intValue > 9999 {
         return 21 // Set a smaller size for large numbers
      } else {
         return 29 // Default size (adjust as needed)
      }
   }
}

#Preview {
   //   @Previewable @State var intValue = 176
   var intValue = 22293
   var topText: String = "TVOC"
   var circleColor: Color = .red
   var sizeOfText : CGFloat = 25
   
   CircularTextViewIntLarge(metricType: .count, topText: topText, intValue: intValue, circleColor: circleColor, sizeOfText: sizeOfText)
   
}
