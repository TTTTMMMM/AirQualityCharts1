//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI

struct HourlyViewAQ: View {
   
   @StateObject var viewModel = AirQualityViewModel()
   @State var selectedDateHour = Calendar.current.date(
      byAdding: .hour,
      value: -2,
      to: Date())!  // defaults to starting one hour back from current time
   @State var numberOfHoursDuration: String = "2"
   @State var charted = false
   @State var displayTemperature = true
   @State var displayHumidity = true
   @State var displayECO2 = true
   @State var displayTVOC = true
   @State var left: Int? = 0

   var body: some View {
      VStack (alignment: .center) {
         HourlyPickerSectionView(
            selectedDateHour: $selectedDateHour,
            numberOfHoursDuration: $numberOfHoursDuration,
            charted: $charted,
            yearDataBegins: 2025,
            monthDataBegins: 9,
            dayDataBegins: 22)
      }
      .task {
         try? await viewModel.getFreebiesLeft()
         await MainActor.run {
            self.left = viewModel.dailyFreebiesLeft
         }
      }
      Spacer()
      Text("Freebies left: \(left ?? 0)")
         .font(.caption2)
         .fullScreenCover(isPresented: $charted) {
            hourlyChartSheet()
         }
         .padding()
         .background(Color.black)
   }
}

#Preview {
   HourlyViewAQ()
}

extension HourlyViewAQ {
   
   func hourlyChartSheet() -> some View {
      VStack () {
         ShowHourlyLineGraphsViewAQ(
            selectedDateHour: $selectedDateHour,
            numberOfHoursDuration: $numberOfHoursDuration,
            displayTemperature: $displayTemperature,
            displayHumidity: $displayHumidity,
            displayECO2: $displayECO2,
            displayTVOC: $displayTVOC
         )
      }
      .ignoresSafeArea()
      .background(.ultraThinMaterial)
      .overlay(
         BackButtonView(charted: $charted),
         alignment: .topLeading)
      .onDisappear {
         Task {
            try await viewModel.getFreebiesLeft()
            await MainActor.run {
               self.left = viewModel.dailyFreebiesLeft
            }
         }
      }
      .overlay(
         CauseAndGraphPickerViewAQ(
            displayTemperature: $displayTemperature,
            displayHumidity: $displayHumidity,
            displayECO2: $displayECO2,
            displayTVOC: $displayTVOC,
            numLeft: $left
         ),
         alignment: .topTrailing
      )
   }
}

