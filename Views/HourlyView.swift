//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI

struct HourlyView: View {

   @StateObject var viewModel = HourlyViewModel()
   @State var selectedDateHour = Calendar.current.date(
      byAdding: .hour,
      value: -2,
      to: Date())!  // defaults to a couple of hours back from current time
   @State var numberOfHoursDuration: String = "3"
   @State var charted = false
   @State var displayTemperature = true
   @State var displayHumidity = true
   @State var displayECO2 = true
   @State var displayTVOC = true
   
   var body: some View {
      VStack (alignment: .center) {
         HourlyPickerSectionView(
            selectedDateHour: $selectedDateHour,
            numberOfHoursDuration: $numberOfHoursDuration,
            charted: $charted)
      }
      Spacer()
         .fullScreenCover(isPresented: $charted) {
            hourlyChartSheet()
         }
         .padding()
         .background(Color.white)
   }
}

#Preview {
   DailyView()
}

extension HourlyView {
   
   func hourlyChartSheet() -> some View {
      VStack () {
         ShowHourlyLineGraphsView(
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
      .overlay(
         CauseAndGraphPickerView(
            displayTemperature: $displayTemperature,
            displayHumidity: $displayHumidity,
            displayECO2: $displayECO2,
            displayTVOC: $displayTVOC),
         alignment: .topTrailing)
   }
}
