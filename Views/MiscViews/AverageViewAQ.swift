import SwiftUI

struct AverageViewAQ: View {
   
   @Binding var avgValuesAQ: AvgValuesAQ
   @Binding var maxValuesAQ: MaxValuesAQ
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 20)
            .fill(Color.gray.opacity(0.2)) // A semi-transparent gray fill
            .frame(height: 200)
            .frame(width: 510)
         VStack() {
            Text("Averages")
               .font(.system(size: 26, weight: .bold, design: .default))
               .foregroundColor(.black)
            HStack (alignment: .top, spacing: 10) {
               CircularTextViewInt(topText: "Temp", intValue: avgValuesAQ.temperature, circleColor: Color.green)
                  .padding(.top, 4)
               CircularTextViewInt(topText: "Humidity", intValue: avgValuesAQ.humidity, circleColor: Color.yellow)
                  .padding(.top, 4)
               CircularTextViewInt(topText: "CO₂", intValue: avgValuesAQ.unbiasedScaledECO2, circleColor: Color.blue)
                  .padding(.top, 4)
               CircularTextViewInt(topText: "TVOC", intValue: avgValuesAQ.scaledTVOC, circleColor: Color.red)
                  .padding(.top, 4)
            }
         }
      }
      .padding()
   }
}

#Preview {
   @Previewable @StateObject var viewModel = AirQualityViewModel()
   
   AverageViewAQ(avgValuesAQ: $viewModel.avgValues, maxValuesAQ: $viewModel.maxValues)
}
