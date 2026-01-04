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
   
   private static func today_Date() -> Date {
      let today = Date()
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month, .day], from: today)
      // Use a nil coalescing operator to provide a fallback date,
      // though this conversion is unlikely to fail.
      return calendar.date(from: components) ?? Date()
   }
   
   private static func theYear(from date: Date) -> Int {
      let calendar = Calendar.current
      let yearComponent = calendar.component(.year, from: date)
      return yearComponent
   }
   
   private static func theMonth(from date: Date) -> Int {
      let calendar = Calendar.current
      let monthComponent = calendar.component(.month, from: date)
      return monthComponent
   }
   
   private static func theDay(from date: Date) -> Int {
      let calendar = Calendar.current
      let dayComponent = calendar.component(.day, from: date)
      return dayComponent
   }

   @StateObject var viewModel = XBarViewModel()
   @State var selectedBeginDate: Date  = july28_2025()
   @State var selectedEndDate: Date = today_Date()
   @State var endDate = Date()
   @State var charted = false
   @State var displayAvgTemperature = true
   @State var displayAvgHumidity    = true
   @State var displayAvgECO2        = true
   @State var displayAvgTVOC        = true
   @State var displayAvgPm03um      = false
   @State var displayAvgPm100s      = true
   @State var left: Int? = 0
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM dd, yyyy"
      return dateFormatter
   }

   var body: some View {
      VStack (alignment: .center) {  // Averages for CO2 and TVOC begins 7/28/2025
         Spacer()
         DatePickerSectionView(
            selectedDate: $selectedBeginDate,
            charted: $charted,
            title: "Pick a Start Date",
            yearDataBegins: 2025,
            monthDataBegins: 7,
            dayDataBegins: 28)
         .padding(.bottom, 50)
         DatePickerSectionView(
            selectedDate: $selectedEndDate,
            charted: $charted,
            title: "Pick an End Date",
            yearDataBegins: XBarView.theYear(from: selectedBeginDate),
            monthDataBegins: XBarView.theMonth(from: selectedBeginDate),
            dayDataBegins: XBarView.theDay(from: selectedBeginDate))
         .padding(.bottom, 50)
         Button(action: {
            charted.toggle()
         },
                label: {
            Text("Graph Daily Averages")
               .font(.headline)
               .foregroundStyle(.white)
         })
         .padding(10)
         .font(.title)
         .background(Color.accentColor)
         .clipShape(RoundedRectangle(cornerRadius: 10))
         .shadow(color: Color.black.opacity(0.9), radius: 10, x: 0, y: 5)
         Spacer()
         Text("Freebies left: \(left ?? 0)")
            .font(.caption2)
            .fullScreenCover(isPresented: $charted) {
               dailyAveragesSheet()
            }
            .padding()
            .background(Color.black)
      }
      .padding(40)
      .task {
         try? await viewModel.getFreebiesLeft()
         await MainActor.run {
            self.left = viewModel.dailyFreebiesLeft
         }
      }
   }
}

#Preview {
   XBarView()
}

extension XBarView {
   
   func dailyAveragesSheet() -> some View {
      VStack () {
         ShowAverageLineGraphsView(
            selectedBeginDate: $selectedBeginDate,
            selectedEndDate: $selectedEndDate,
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
