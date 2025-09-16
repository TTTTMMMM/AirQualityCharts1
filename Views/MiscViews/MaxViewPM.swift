import SwiftUI

struct MaxViewPM: View {
   
   @Binding var maxValuesPM: MaxValuesPM
   
   var body: some View {
      ZStack {
         RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white, lineWidth: 1)
            .fill(Color.gray.opacity(0.1))     // A semi-transparent gray fill
            .frame(width: 530, height: 200)
            .shadow(color: .green.opacity(0.4), radius: 10, x: 5, y: 5)
         VStack() {
            Text("Maximums")
               .font(.system(size: 26, weight: .bold, design: .default))
               .foregroundColor(.white)
            HStack (alignment: .top, spacing: 10) {
               CircularTextViewInt(metricType: .count, topText: "0.3 μm", intValue: maxValuesPM.pm03um, circleColor: Color.green, sizeOfText: 30)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "PM1.0", intValue: maxValuesPM.pm10s, circleColor: Color.yellow, sizeOfText: 45)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "PM2.5", intValue: maxValuesPM.pm25s, circleColor: Color.blue, sizeOfText: 45)
                  .padding(.top, 4)
               CircularTextViewInt(metricType: .count, topText: "PM10", intValue: maxValuesPM.pm100s, circleColor: Color.red, sizeOfText: 45)
                  .padding(.top, 4)
            }
         }
      }
      .padding()
   }
}

#Preview {
   @Previewable @StateObject var viewModel = ParticleCountsViewModel()
   
   MaxViewPM(maxValuesPM: $viewModel.maxValues)
}
