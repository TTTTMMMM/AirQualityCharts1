//
// https://www.youtube.com/playlist?list=PLwvDm4Vfkdphl8ly0oi0aHx0v2B7UvDK0
//
import SwiftUI

struct RealTimeListenerViewPM: View {

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
   
   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM dd, yyyy"
      return dateFormatter
   }

   var body: some View {
      VStack (alignment: .center) {
         Button(action: {
            charted.toggle()
         },
                label: {
            Text("Realtime Particulate Matter\n \(self.dateFormatter.string(from: self.selectedDate))")
               .font(.headline)
               .foregroundStyle(.white)
         })
         .padding(10)
         .font(.title)
         .background(Color.accentColor)
         .clipShape(RoundedRectangle(cornerRadius: 10))
         .shadow(color: Color.black.opacity(0.9), radius: 10, x: 0, y: 5)      }
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
            realTimeChartSheet()
         }
         .padding()
         .background(Color.black)
   }
}

#Preview {
   RealTimeListenerViewPM()
}

extension RealTimeListenerViewPM {
   
   func realTimeChartSheet() -> some View {
      VStack () {
         ShowRealTimeLineGraphViewPM(
            displayPM03um: $displayPM03um,
            displayPM05um: $displayPM05um,
            displayPM1um:  $displayPM1um,
            displayPM25um: $displayPM25um,
            displayPM5um:  $displayPM5um,
            displayPM10um: $displayPM10um
         )
      }
      .ignoresSafeArea()
      .background(.gray)
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
   }
}
