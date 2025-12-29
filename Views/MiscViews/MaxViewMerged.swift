import SwiftUI

struct MaxViewMerged: View {
   
   @Binding var maxValuesMerged: MaxValuesMerged
   var titleOfPanel: String
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white, lineWidth: 1)
            .fill(Color.gray.opacity(0.1))     // A semi-transparent gray fill
            .frame(width: 700, height: 180)
            .shadow(color: .green.opacity(0.4), radius: 10, x: 5, y: 5)
         VStack() {
            Text(titleOfPanel)
               .font(.system(size: 26, weight: .bold, design: .default))
               .foregroundColor(.white)
            HStack (alignment: .top, spacing: 10) {
               CircularTextViewDbl(
                  metricType: .temperature,
                  topText: "Temp",
                  dblValue: maxValuesMerged.temperature,
                  circleColor: Color.green
               )
               .padding(.top, 4)
               CircularTextViewDbl(
                  metricType: .humidity,
                  topText: "Humidity",
                  dblValue: maxValuesMerged.humidity,
                  circleColor: Color.yellow
               )
               .padding(.top, 4)
               CircularTextViewInt(
                  metricType: .count,
                  topText: "CO₂",
                  intValue: maxValuesMerged.unbiasedScaledECO2,
                  circleColor: Color.blue,
                  sizeOfText: 29
               )
               .padding(.top, 4)
               CircularTextViewInt(
                  metricType: .count,
                  topText: "TVOC",
                  intValue: maxValuesMerged.scaledTVOC,
                  circleColor: Color.red,
                  sizeOfText: 29
               )
               .padding(.top, 4)
               CircularTextViewInt(
                  metricType: .count,
                  topText: "0.3 μm",
                  intValue: maxValuesMerged.pm03um,
                  circleColor: Color.mint,
                  sizeOfText: 29
               )
               .padding(.top, 4)
               CircularTextViewInt(
                  metricType: .count,
                  topText: "PM10",
                  intValue: maxValuesMerged.pm100s,
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
   var titleOfPanel = "Maximums"
   
   MaxViewMerged(maxValuesMerged: $viewModel.maxValuesMerged, titleOfPanel: titleOfPanel)
}
