import Foundation
import SwiftUI

struct ChartListViewModel: Identifiable {
   let id = UUID().uuidString
   let ind: Int
   let imageName: String
   let listDisplayText: String
   let chartView: AnyView
}


// Daily Averages
let dailyAveragesView = ChartListViewModel(
   ind: 0,
   imageName: "x-bar",
   listDisplayText: "X꛱ Chart",
   chartView: AnyView(XBarView()))

// Merged Samples
let realtimeViewMerged = ChartListViewModel(
   ind: 1,
   imageName: "pm3",
   listDisplayText: "Real Time Listener",
   chartView: AnyView(RealTimeListenerViewMerged()))
let dailyViewMerged = ChartListViewModel(
   ind: 2,
   imageName: "pm1",
   listDisplayText: "Daily",
   chartView: AnyView(DailyViewMerged()))
let hourlyViewMerged = ChartListViewModel(
   ind: 3,
   imageName: "pm2",
   listDisplayText: "Hourly",
   chartView: AnyView(HourlyViewMerged()))
let clvmArray: [ChartListViewModel] = [
   dailyAveragesView,
   realtimeViewMerged,
   dailyViewMerged,
   hourlyViewMerged
]

