import SwiftUI

struct AverageViewMerged: View {
   
   @Binding var avgValuesMerged: AvgValuesMerged
   var titleOfPanel: String
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white, lineWidth: 1)
            .fill(Color.gray.opacity(0.1))     // A semi-transparent gray fill
            .frame(width: 690, height: 190)
            .shadow(color: .green.opacity(0.4), radius: 10, x: 5, y: 5)
         VStack() {
            Text(titleOfPanel)
               .font(.system(size: 26, weight: .bold, design: .default))
               .foregroundColor(.white)
            HStack (alignment: .top, spacing: 10) {
               CircularTextViewInt(
                  metricType: .temperature,
                  topText: "Temp",
                  intValue: avgValuesMerged.temperature,
                  circleColor: Color.green,
                  sizeOfText: 29
               )
               .padding(.top, 4)
               CircularTextViewInt(
                  metricType: .humidity,
                  topText: "Humidity",
                  intValue: avgValuesMerged.humidity,
                  circleColor: Color.yellow,
                  sizeOfText: 29
               )
               .padding(.top, 4)
               CircularTextViewInt(
                  metricType: .count,
                  topText: "CO₂",
                  intValue: avgValuesMerged.unbiasedScaledECO2,
                  circleColor: Color.blue,
                  sizeOfText: 29
               )
               .padding(.top, 4)
               CircularTextViewInt(
                  metricType: .count,
                  topText: "TVOC",
                  intValue: avgValuesMerged.scaledTVOC,
                  circleColor: Color.red,
                  sizeOfText: 29
               )
               .padding(.top, 4)
               CircularTextViewInt(
                  metricType: .count,
                  topText: "0.3 μm",
                  intValue: avgValuesMerged.pm03um,
                  circleColor: Color.mint,
                  sizeOfText: 29
               )
               .padding(.top, 4)
               CircularTextViewInt(
                  metricType: .count,
                  topText: "PM10",
                  intValue: avgValuesMerged.pm100s,
                  circleColor: Color.purple,
                  sizeOfText: 29
               )
               .padding(.top, 4)
            }
         }
      }
      .padding()
   }
}

#Preview {
   @Previewable @StateObject var viewModel = MergedSamplesViewModel()
   var titleOfPanel = "Average"
   
   AverageViewMerged(avgValuesMerged: $viewModel.avgValuesMerged, titleOfPanel: titleOfPanel)
}
