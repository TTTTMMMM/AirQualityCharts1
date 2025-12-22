//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI

struct HourlyViewPM: View {
   
   @StateObject var viewModel = ParticleCountsViewModel()
   @State var selectedDateHour = Calendar.current.date(
      byAdding: .hour,
      value: -2,
      to: Date())!  // defaults to starting two hours back from current time
   @State var numberOfHoursDuration: String = "2"
   @State var charted = false
   @State var displayPM03um = true
   @State var displayPM10s  = true
   @State var displayPM25s  = true
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
   HourlyViewPM()
}

extension HourlyViewPM {
   
   func hourlyChartSheet() -> some View {
      VStack () {
         ShowHourlyLineGraphsViewPM(
            selectedDateHour: $selectedDateHour,
            numberOfHoursDuration: $numberOfHoursDuration,
            displayPM03um: $displayPM03um,
            displayPM10s: $displayPM10s,
            displayPM25s: $displayPM25s,
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
         CauseAndGraphPickerViewPM(
            displayPM03um: $displayPM03um,
            displayPM10s: $displayPM10s,
            displayPM25s: $displayPM25s,
            displayPM100s: $displayPM100s,
            numLeft: $left
         ),
         alignment: .topTrailing)
      }
   }

