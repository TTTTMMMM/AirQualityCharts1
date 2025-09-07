//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI

struct DailyViewAQ: View {

   @StateObject var viewModel = AirQualityViewModel()
   @State var selectedDate = Date()
   @State var charted = false
   @State var displayTemperature = true
   @State var displayHumidity = true
   @State var displayECO2 = true
   @State var displayTVOC = true
   @State var left: Int? = 0

   var body: some View {
      VStack (alignment: .center) {
         DatePickerSectionView(selectedDate: $selectedDate, charted: $charted)
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
   DailyViewAQ()
}

extension DailyViewAQ {
   
   func dailyChartSheet() -> some View {
      VStack () {
         ShowDailyLineGraphsViewAQ(
            selectedDate: $selectedDate,
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
         alignment: .topTrailing)
   }
}
