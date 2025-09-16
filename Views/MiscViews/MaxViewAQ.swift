import SwiftUI

struct MaxViewAQ: View {
   
   @Binding var maxValuesAQ: MaxValuesAQ
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white, lineWidth: 1)
            .fill(Color.gray.opacity(0.1))     // A semi-transparent gray fill
            .frame(width: 520, height: 200)
            .shadow(color: .green.opacity(0.4), radius: 10, x: 5, y: 5)
         VStack() {
            Text("Maximums")
               .font(.system(size: 26, weight: .bold, design: .default))
               .foregroundColor(.white)
            HStack (alignment: .top, spacing: 10) {
               CircularTextViewDbl(metricType: .temperature, topText: "Temp", dblValue: maxValuesAQ.temperature, circleColor: Color.green)
                  .padding(.top, 4)
               CircularTextViewDbl(metricType: .humidity, topText: "Humidity", dblValue: maxValuesAQ.humidity, circleColor: Color.yellow)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "CO₂", intValue: maxValuesAQ.unbiasedScaledECO2, circleColor: Color.blue, sizeOfText: 40)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "TVOC", intValue: maxValuesAQ.scaledTVOC, circleColor: Color.red, sizeOfText: 40)
                  .padding(.top, 4)
            }
         }
      }
      .padding()
   }
}

#Preview {
   @Previewable @StateObject var viewModel = AirQualityViewModel()
   
   MaxViewAQ(maxValuesAQ: $viewModel.maxValues)
}
