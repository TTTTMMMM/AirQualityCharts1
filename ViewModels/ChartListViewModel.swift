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

// Air Quality Samples
let dailyViewAQ = ChartListViewModel(
   ind: 1,
   imageName: "Line-Graph",
   listDisplayText: "Daily",
   chartView: AnyView(DailyViewAQ()))
   //   chartView: AnyView(DailyViewAQ1()))
let hourlyViewAQ = ChartListViewModel(
   ind: 2,
   imageName: "bar-chart",
   listDisplayText: "Hourly",
   chartView: AnyView(HourlyViewAQ()))
let realtimeViewAQ = ChartListViewModel(
   ind: 3,
   imageName: "realTimeListener",
   listDisplayText: "Real Time Listener",
   chartView: AnyView(RealTimeListenerViewAQ()))

// Particulate Matter Samples
let dailyViewPM = ChartListViewModel(
   ind: 4,
   imageName: "pm1",
   listDisplayText: "Daily",
   chartView: AnyView(DailyViewPM()))
let hourlyViewPM = ChartListViewModel(
   ind: 5,
   imageName: "pm2",
   listDisplayText: "Hourly",
   chartView: AnyView(HourlyViewPM()))
let realtimeViewPM = ChartListViewModel(
   ind: 6,
   imageName: "pm3",
   listDisplayText: "Real Time Listener",
   chartView: AnyView(RealTimeListenerViewPM()))

// Merged Samples
let realtimeViewMerged = ChartListViewModel(
   ind: 7,
   imageName: "mergedImage",
   listDisplayText: "Real Time Merged Listener",
   chartView: AnyView(RealTimeListenerViewMerged()))
let dailyViewMerged = ChartListViewModel(
   ind: 8,
   imageName: "pm1",
   listDisplayText: "Daily",
   chartView: AnyView(DailyViewMerged()))
let hourlyViewMerged = ChartListViewModel(
   ind: 9,
   imageName: "pm2",
   listDisplayText: "Hourly",
   chartView: AnyView(HourlyViewMerged()))
let clvmArray: [ChartListViewModel] = [
   dailyAveragesView,
   dailyViewAQ,
   hourlyViewAQ,
   realtimeViewAQ,
   dailyViewPM,
   hourlyViewPM,
   realtimeViewPM,
   realtimeViewMerged,
   dailyViewMerged,
   hourlyViewMerged
]

