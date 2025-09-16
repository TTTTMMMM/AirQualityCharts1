//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI

struct DailyViewPM: View {

   @StateObject var viewModel = ParticleCountsViewModel()
   @State var selectedDate = Date()
   @State var charted = false
   @State var displayPM03um = true
   @State var displayPM10s  = true
   @State var displayPM25s  = true
   @State var displayPM100s = true
   @State var left: Int? = 0

   var body: some View {
      VStack (alignment: .center) {  // Data collection for Particulates begins 9/15/2025
         DatePickerSectionView(
            selectedDate: $selectedDate,
            charted: $charted,
            yearDataBegins: 2025,
            monthDataBegins: 9,
            dayDataBegins: 15)
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
   DailyViewPM()
}

extension DailyViewPM {
   
   func dailyChartSheet() -> some View {
      VStack () {
         ShowDailyLineGraphsViewPM(
            selectedDate: $selectedDate,
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
            displayPM10s:  $displayPM10s,
            displayPM25s:  $displayPM25s,
            displayPM100s: $displayPM100s,
            numLeft: $left
         ),
         alignment: .topTrailing)
   }
}
