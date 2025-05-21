//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI
import Charts

struct DailyView: View {

   @StateObject var viewModel = DailyViewModel()
   @State var selectedDate = Date()
   @State var charted = false
   @State var displayTemperature = true
   @State var displayHumidity = true
   @State var displayECO2 = true
   @State var displayTVOC = true
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM dd, yyyy"
      return dateFormatter
   }
   private var dateFormatter2: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
      return dateFormatter
   }
   
   var body: some View {
      VStack (alignment: .center) {
         DatePickerSectionView(selectedDate: $selectedDate, charted: $charted)
      }
      Spacer()
         .fullScreenCover(isPresented: $charted) {
            dailyChartSheet()
         }
         .padding()
         .background(Color.white)
   }
}


#Preview {
   DailyView()
}

extension DailyView {
   
   func dailyChartSheet() -> some View {
      VStack () {
         ShowDailyLineGraphsView(
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
      .overlay(
         CauseAndGraphPickerView(
            displayTemperature: $displayTemperature,
            displayHumidity: $displayHumidity,
            displayECO2: $displayECO2,
            displayTVOC: $displayTVOC),
         alignment: .topTrailing)
   }
}
