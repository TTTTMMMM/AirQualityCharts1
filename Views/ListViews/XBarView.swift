//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI

struct XBarView: View {
   
   private static func july28_2025() -> Date {
       var dateComponents = DateComponents()
       dateComponents.year = 2025
       dateComponents.month = 7
       dateComponents.day = 28
       
       let calendar = Calendar.current
       // Use a nil coalescing operator to provide a fallback date,
       // though this conversion is unlikely to fail.
       return calendar.date(from: dateComponents) ?? Date()
   }

   @StateObject var viewModel = XBarViewModel()
   @State var selectedDate: Date  = july28_2025()
   @State var endDate = Date()
   @State var charted = false
   @State var displayAvgTemperature = true
   @State var displayAvgHumidity    = true
   @State var displayAvgECO2        = true
   @State var displayAvgTVOC        = true
   @State var displayAvgPm03um      = true
   @State var displayAvgPm100s      = true
   @State var left: Int? = 0

   var body: some View {
      VStack (alignment: .center) {  // Averages for CO2 and TVOC begins 7/28/2025
         DatePickerSectionView(
            selectedDate: $selectedDate,
            charted: $charted,
            yearDataBegins: 2025,
            monthDataBegins: 7,
            dayDataBegins: 28)
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
            dailyAveragesSheet()
         }
         .padding()
         .background(Color.black)
   }
}

#Preview {
   XBarView()
}

extension XBarView {
   
   func dailyAveragesSheet() -> some View {
      VStack () {
         ShowAverageLineGraphsView(
            selectedDate: $selectedDate,
            endDate: $endDate,
            displayAvgTemperature: $displayAvgTemperature,
            displayAvgHumidity: $displayAvgHumidity,
            displayAvgECO2: $displayAvgECO2,
            displayAvgTVOC: $displayAvgTVOC,
            displayAvgPm03um: $displayAvgPm03um,
            displayAvgPm100s: $displayAvgPm100s
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
         AveragePickerView(
            displayAvgTemperature: $displayAvgTemperature,
            displayAvgHumidity: $displayAvgHumidity,
            displayAvgECO2: $displayAvgECO2,
            displayAvgTVOC: $displayAvgTVOC,
            displayAvgPm03um: $displayAvgPm03um,
            displayAvgPm100s: $displayAvgPm100s,
            numLeft: $left
         ),
         alignment: .topTrailing)
   }
}
