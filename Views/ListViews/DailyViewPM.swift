//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI

struct DailyViewPM: View {

   @StateObject var viewModel = ParticleCountsViewModel()
   @State var selectedDate = Date()
   @State var charted = false
   @State var displayPM03um = true
   @State var displayPM05um = true
   @State var displayPM1um  = true
   @State var displayPM25um = true
   @State var displayPM5um  = true
   @State var displayPM10um = true
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
   DailyViewPM()
}

extension DailyViewPM {
   
   func dailyChartSheet() -> some View {
      VStack () {
         ShowDailyLineGraphsViewPM(
            selectedDate: $selectedDate,
            displayPM03um: $displayPM03um,
            displayPM05um: $displayPM05um,
            displayPM1um: $displayPM1um,
            displayPM25um: $displayPM25um
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
            displayPM05um: $displayPM05um,
            displayPM1um: $displayPM1um,
            displayPM25um: $displayPM25um,
            numLeft: $left
         ),
         alignment: .topTrailing)
   }
}
