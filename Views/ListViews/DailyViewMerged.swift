//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI

struct DailyViewMerged: View {

   @StateObject var viewModel = AirQualityViewModel()
   @State var selectedDate = Date()
   @State var charted = false
   @State var displayTemperature = true
   @State var displayHumidity    = true
   @State var displayECO2        = true
   @State var displayTVOC        = true
   @State var displayPM03um      = false
   @State var displayPM100s      = true
   @State var left: Int? = 0

   var body: some View {
      VStack (alignment: .center) {  // Data collection for CO2 and TVOC begins 9/22/2025
         DatePickerSectionView(
            selectedDate: $selectedDate,
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
            dailyChartSheet()
         }
         .padding()
         .background(Color.black)
   }
}

#Preview {
   DailyViewMerged()
}

extension DailyViewMerged {
   
   func dailyChartSheet() -> some View {
      VStack () {
         ShowDailyLineGraphsViewMerged(
            selectedDate: $selectedDate,
            displayTemperature: $displayTemperature,
            displayHumidity: $displayHumidity,
            displayECO2: $displayECO2,
            displayTVOC: $displayTVOC,
            displayPM03um: $displayPM03um,
            displayPM100s: $displayPM100s
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
         HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
               CauseAndGraphPickerViewMerged(
                  displayTemperature: $displayTemperature,
                  displayHumidity: $displayHumidity,
                  displayECO2: $displayECO2,
                  displayTVOC: $displayTVOC,
                  displayPM03um: $displayPM03um,
                  displayPM100s: $displayPM100s,
                  numLeft: $left
               )
               Spacer()
            }
         }
      )
   }
}
