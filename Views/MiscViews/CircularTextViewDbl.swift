import SwiftUI

struct CircularTextViewDbl: View {
   var metricType: MetricType
   var topText: String
   var dblValue: Double
   var circleColor: Color
   
   var body: some View {
      VStack {
          Text(topText)
              .font(.headline)
         switch metricType {
            case .humidity:
               Text(String(format: "%.1f%%", dblValue))
                  .font(.system(size: 24, weight: .bold, design: .default))
            case .temperature:
               Text(String(format: "%.1f°", dblValue))
                  .font(.system(size: 24, weight: .bold, design: .default))
            case .count:
               Text(String(format: "%.1f", dblValue))
                  .font(.system(size: 24, weight: .bold, design: .default))
         }
      }
      .padding(25)
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
   
   CircularTextViewDbl(metricType: .temperature, topText: topText, dblValue: dblValue, circleColor: circleColor)

}
