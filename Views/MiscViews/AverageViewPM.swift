import SwiftUI

struct AverageViewPM: View {
   
   @Binding var avgValuesPM: AvgValuesPM
   
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
               CircularTextViewInt(metricType: .count, topText: "0.3 μm", intValue: avgValuesPM.pm03um, circleColor: Color.green, sizeOfText: 40)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "0.5 μm", intValue: avgValuesPM.pm05um, circleColor: Color.yellow, sizeOfText: 40)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "1.0 μm", intValue: avgValuesPM.pm1um, circleColor: Color.blue, sizeOfText: 40)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "2.5 μm", intValue: avgValuesPM.pm25um, circleColor: Color.red, sizeOfText: 40)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "5.0 μm", intValue: avgValuesPM.pm5um, circleColor: Color.purple, sizeOfText: 40)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "10 μm", intValue: avgValuesPM.pm10um, circleColor: Color.mint, sizeOfText: 40)
                  .padding(.top, 4)
            }
         }
      }
      .padding()
   }
}

#Preview {
   @Previewable @StateObject var viewModel = ParticleCountsViewModel()
   
   AverageViewPM(avgValuesPM: $viewModel.avgValues)
}
