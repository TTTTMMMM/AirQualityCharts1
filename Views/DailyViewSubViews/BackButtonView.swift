import SwiftUI

struct BackButtonView: View {
   
   @Binding var charted: Bool
   @StateObject var viewModel = DailyViewModel()

   var body: some View {
      Button(action: {
         charted.toggle()
         Task {
            do {
               try await viewModel.clearAQMeasurements()
            }
            catch {
               print(error.localizedDescription)
            }
         }
      }, label: {
         Image(systemName: "clear")
            .font(.title2)
            .padding(6)
            .foregroundStyle(.primary)
            .background(.thickMaterial)
            .cornerRadius(10)
            .shadow(radius: 4)
      })
      .padding(.leading, 45)
   }
}

#Preview {
   BackButtonView(charted: .constant(true))
}
