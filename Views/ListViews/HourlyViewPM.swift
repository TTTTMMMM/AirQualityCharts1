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
   @State var displayPM05um = true
   @State var displayPM1um  = true
   @State var displayPM25um = true
   @State var displayPM5um  = true
   @State var displayPM10um = true
   @State var left: Int? = 0

   var body: some View {
      VStack (alignment: .center) {
         HourlyPickerSectionView(
            selectedDateHour: $selectedDateHour,
            numberOfHoursDuration: $numberOfHoursDuration,
            charted: $charted)
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
            displayPM05um: $displayPM05um,
            displayPM1um: $displayPM1um,
            displayPM25um: $displayPM25um,
            displayPM5um: $displayPM5um,
            displayPM10um: $displayPM10um
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
            displayPM1um:  $displayPM1um,
            displayPM25um: $displayPM25um,
            displayPM5um:  $displayPM5um,
            displayPM10um: $displayPM10um,
            numLeft: $left
         ),
         alignment: .topTrailing)
      }
   }

