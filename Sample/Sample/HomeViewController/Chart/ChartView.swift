//
//  ChartView.swift
//  Sample
//
//  Created by Eugene Naloiko on 23.01.2023.
//

import UIKit
import WoundGenius

class ChartView: UIView {
    
    private lazy var chartView: LineChartView = {
        let chartView = LineChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.chartDescription.enabled = false
        chartView.setScaleEnabled(false)
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.pinchZoomEnabled = false
        chartView.isUserInteractionEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.valueFormatter = DateValueFormatter()
        xAxis.granularity = 60*60*24
        xAxis.drawGridLinesEnabled = false

        self.addSubview(chartView)
        NSLayoutConstraint.activate([
            chartView.leftAnchor.constraint(equalTo: self.leftAnchor),
            chartView.topAnchor.constraint(equalTo: self.topAnchor),
            chartView.rightAnchor.constraint(equalTo: self.rightAnchor),
            chartView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        return chartView
    }()
    
    func updateChartData(series: [Series], tableView: UITableView) {
        /* We are going to display in the chart only the series, which have single measurement. To show single point at a time. */
        let seriesWithSingleMeasurement = series.filter {
            return $0.captureResults.compactMap {
                switch $0 {
                case .measurement(let measurement):
                    return measurement
                default:
                    return nil
                }
            }.count == 1
        }
        
        /* Show the chart only if at least 2 data items are available */
        guard seriesWithSingleMeasurement.count >= 2 else {
            self.frame = CGRect.zero
            return
        }
        
        /* Prepare the data values. With xValue and yValue. Where xValue - is the date. yValue - is the measurement total area. */
        let values = (0..<seriesWithSingleMeasurement.count).map { (index) -> ChartDataEntry in
            let series = seriesWithSingleMeasurement[index]
            let measurement = series.captureResults.compactMap {
                switch $0 {
                case .measurement(let measurement):
                    return measurement
                default:
                    return nil
                }
            }.first!
            
            return ChartDataEntry(x: series.timestamp, y: Double(Int(measurement.outlines.compactMap({
                $0.areaInCM ?? 0
            }).reduce(0, +))))
        }
        
        /* Setup the Set */
        let set = LineChartDataSet(entries: values, label: L.str("AREA"))
        if let firstAssessmentTimestamp = seriesWithSingleMeasurement.first?.timestamp, let lastAssessmentTimestamp = seriesWithSingleMeasurement.last?.timestamp {
            self.chartView.xAxis.spaceMin = (lastAssessmentTimestamp - firstAssessmentTimestamp) * 0.03
            self.chartView.xAxis.spaceMax = (lastAssessmentTimestamp - firstAssessmentTimestamp) * 0.04
        }
        
        set.drawIconsEnabled = false
        set.setColor(UIColor.red)
        set.setCircleColor(UIColor.red)
        set.highlightColor = UIColor.red
        set.lineWidth = 1
        set.circleRadius = 2
        set.drawCircleHoleEnabled = false
        set.valueFont = .systemFont(ofSize: 8)
        set.formLineDashLengths = [5, 2.5]
        set.formLineWidth = 1
        set.formSize = 15
        set.mode = .horizontalBezier
        
        let data = LineChartData(dataSet: set)
        chartView.data = data
        
        /* Highlight the last added item in the data */
        if let lastValue = values.last {
            chartView.highlightValue(Highlight(x: lastValue.x, y: lastValue.y, dataSetIndex: 0))
        }
        
        self.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 180)
    }
}

public class DateValueFormatter: NSObject, AxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}
