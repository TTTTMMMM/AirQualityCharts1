import Foundation
import SwiftUI

struct ChartListViewModel: Identifiable {
   let id = UUID().uuidString
   let ind: Int
   let imageName: String
   let listDisplayText: String
   let chartView: AnyView
}

//Air Quality Samples
let dailyViewAQ = ChartListViewModel(
   ind: 0,
   imageName: "Line-Graph",
   listDisplayText: "Daily",
   chartView: AnyView(DailyViewAQ()))
let weeklyViewAQ = ChartListViewModel(
   ind: 1,
   imageName: "bar-chart",
   listDisplayText: "Hourly",
   chartView: AnyView(HourlyViewAQ()))
let dailyComparisonViewAQ = ChartListViewModel(
   ind: 2,
   imageName: "realTimeListener",
   listDisplayText: "Real Time Listener",
   chartView: AnyView(RealTimeListenerViewAQ()))

//Particulate Matter Samples
let dailyViewPM = ChartListViewModel(
   ind: 3,
   imageName: "pm1",
   listDisplayText: "Daily",
   chartView: AnyView(DailyViewPM()))
let weeklyViewPM = ChartListViewModel(
   ind: 4,
   imageName: "pm2",
   listDisplayText: "Hourly",
   chartView: AnyView(HourlyViewPM()))
let dailyComparisonViewPM = ChartListViewModel(
   ind: 5,
   imageName: "pm3",
   listDisplayText: "Real Time Listener",
   chartView: AnyView(RealTimeListenerViewAQ()))

let clvmArray: [ChartListViewModel] = [dailyViewAQ, weeklyViewAQ, dailyComparisonViewAQ, dailyViewPM, weeklyViewPM, dailyComparisonViewPM]

