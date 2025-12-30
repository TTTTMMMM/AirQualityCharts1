//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI

struct HourlyViewMerged: View {
   
   @StateObject var viewModelMerged = MergedSamplesViewModel()
   @State var selectedDateHour = Calendar.current.date(
      byAdding: .hour,
      value: -2,
      to: Date())!  // defaults to starting one hour back from current time
   @State var numberOfHoursDuration: String = "1"
   @State var charted = false
   @State var displayTemperature = true
   @State var displayHumidity = true
   @State var displayECO2 = true
   @State var displayTVOC = true
   @State var displayPM03um = false
   @State var displayPM100s = true
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
         try? await viewModelMerged.getFreebiesLeft()
         await MainActor.run {
            self.left = viewModelMerged.dailyFreebiesLeft
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
   HourlyViewMerged()
}

extension HourlyViewMerged {
   
   func hourlyChartSheet() -> some View {
      VStack () {
         ShowHourlyLineGraphsViewMerged(
            selectedDateHour: $selectedDateHour,
            numberOfHoursDuration: $numberOfHoursDuration,
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
            try await viewModelMerged.getFreebiesLeft()
            await MainActor.run {
               self.left = viewModelMerged.dailyFreebiesLeft
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

