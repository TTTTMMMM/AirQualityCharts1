import SwiftUI

struct LastSampleView: View {
   @StateObject var viewModel = AirQualityViewModel()

   private var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "YYYY-MMM-dd HH:mm"
      return dateFormatter
   }
   
    var body: some View {
       
       VStack (alignment: .leading) {
          Text(verbatim: "id: \(viewModel.lastSample.id)")
          Text(verbatim: "temperature: \(viewModel.lastSample.temperature)°F")
          Text(verbatim: "humidity: \(viewModel.lastSample.humidity)")
          Text("eCO2: \(viewModel.lastSample.eCO2)")
          Text("TVOC: \(viewModel.lastSample.tVOC)")
          Text("\(dateFormatter.string(from: viewModel.lastSample.dt))")
       }
       .font(.subheadline)
       .padding(6)
       .background(Color.gray.opacity(0.1))
       .clipShape(RoundedRectangle(cornerRadius: 10))
       .overlay(
           RoundedRectangle(cornerRadius: 6)
               .stroke(.black, lineWidth: 1)
       )
       .frame(width: 190)
       .transition(.opacity)
       .animation(.linear(duration: 0.6), value: viewModel.lastSample)

    }
}

#Preview {
   LastSampleView()
}
