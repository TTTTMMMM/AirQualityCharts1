import SwiftUI

struct AverageViewAQ: View {
   
   @Binding var avgValuesAQ: AvgValuesAQ
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white, lineWidth: 1)
            .fill(Color.gray.opacity(0.1))     // A semi-transparent gray fill
            .frame(width: 530, height: 200)
         VStack() {
            Text("Averages")
               .font(.system(size: 26, weight: .bold, design: .default))
               .foregroundColor(.white)
            HStack (alignment: .top, spacing: 10) {
               CircularTextViewInt(metricType: .temperature, topText: "Temp", intValue: avgValuesAQ.temperature, circleColor: Color.green, sizeOfText: 48)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .humidity, topText: "Humidity", intValue: avgValuesAQ.humidity, circleColor: Color.yellow, sizeOfText: 48)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "CO₂", intValue: avgValuesAQ.unbiasedScaledECO2, circleColor: Color.blue, sizeOfText: 50)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "TVOC", intValue: avgValuesAQ.scaledTVOC, circleColor: Color.red, sizeOfText: 50)
                  .padding(.top, 4)
            }
         }
      }
      .padding()
   }
}

#Preview {
   @Previewable @StateObject var viewModel = AirQualityViewModel()
   
   AverageViewAQ(avgValuesAQ: $viewModel.avgValues)
}
