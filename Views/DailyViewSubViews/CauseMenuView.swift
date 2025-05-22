import SwiftUI

struct CauseMenuView: View {
   
   @StateObject private var viewModel = CauseMenuViewModel()
   
   var body: some View {
      Menu("Cause: \(viewModel.selectedCause?.rawValue.capitalized ?? "")") {
         ForEach(CauseMenuViewModel.Cause.allCases, id: \.self) { cause in
            Button {
               Task {
                  await viewModel.updateCause(reason: cause)
               }
            } label: {
               HStack{
                  Text(cause.rawValue)
                  Image(systemName: "wind.snow")
               }
            }
         }
      }
      .font(.subheadline)
      .foregroundStyle(Color.black)
      .padding(5)
      .clipShape(RoundedRectangle(cornerRadius: 1))
   }
}

#Preview {
    CauseMenuView()
}
