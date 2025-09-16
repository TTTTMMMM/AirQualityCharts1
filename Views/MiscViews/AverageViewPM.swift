import SwiftUI

struct AverageViewPM: View {
   
   @Binding var avgValuesPM: AvgValuesPM
   var titleOfPanel: String
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white, lineWidth: 1)
            .fill(Color.gray.opacity(0.1))     // A semi-transparent gray fill
            .frame(width: 510, height: 200)
            .shadow(color: .green.opacity(0.4), radius: 10, x: 5, y: 5)
         VStack() {
            Text(titleOfPanel)
               .font(.system(size: 26, weight: .bold, design: .default))
               .foregroundColor(.white)
            HStack (alignment: .top, spacing: 10) {
               CircularTextViewInt(metricType: .count, topText: "0.3 μm", intValue: avgValuesPM.pm03um, circleColor: Color.green, sizeOfText: 31)
                  .padding(.top,3)
               CircularTextViewInt(metricType: .count, topText: "PM1.0", intValue: avgValuesPM.pm10s, circleColor: Color.yellow, sizeOfText: 46)
                  .padding(.top, 3)
               CircularTextViewInt(metricType: .count, topText: "PM2.5", intValue: avgValuesPM.pm25s, circleColor: Color.blue, sizeOfText: 46)
                  .padding(.top, 3)
               CircularTextViewInt(metricType: .count, topText: "PM10", intValue: avgValuesPM.pm100s, circleColor: Color.red, sizeOfText: 46)
                  .padding(.top, 3)
            }
         }
      }
      .padding()
   }
}

#Preview {
   @Previewable @StateObject var viewModel = ParticleCountsViewModel()
   var titleOfPanel = "Averages"
   
   AverageViewPM(avgValuesPM: $viewModel.avgValues, titleOfPanel: titleOfPanel)
}
