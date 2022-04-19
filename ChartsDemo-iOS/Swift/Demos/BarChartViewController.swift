//
//  BarChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

#if canImport(UIKit)
    import UIKit
#endif
import Charts
#if canImport(UIKit)
    import UIKit
#endif

class BarChartViewController: DemoBaseViewController {
    
    @IBOutlet var chartView: BarChartView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!
    @IBOutlet var sliderTextX: UITextField!
    @IBOutlet var sliderTextY: UITextField!
    
    var lineView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Bar Chart"
        
        self.options = [.toggleValues,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleData,
                        .toggleBarBorders]
        
        self.setup(barLineChartView: chartView)
        
        chartView.delegate = self
        
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        
        chartView.maxVisibleCount = 60
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DayAxisValueFormatter(chart: chartView)
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = " $"
        leftAxisFormatter.positiveSuffix = " $"
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
//        leftAxis.spaceTop = 0.15
        leftAxis.spaceTop = 0
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = leftAxis.valueFormatter
//        rightAxis.spaceTop = 0.15
        rightAxis.spaceTop = 0
        rightAxis.axisMinimum = 0
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4
//        chartView.legend = l

        let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                  font: .systemFont(ofSize: 12),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: chartView.xAxis.valueFormatter!)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
        
        sliderX.value = 12
        sliderY.minimumValue = 0
        sliderY.maximumValue = 5
        sliderY.value = 2
        slidersValueChanged(nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let contentRect = chartView.contentRect
        

        
        let overlay = UIView(frame: contentRect)
        overlay.backgroundColor = UIColor(red: 0, green: 1.0, blue: 1.0, alpha: 0.4)
        self.chartView.addSubview(overlay)
        
        print("Content rect: \(contentRect)")
        
        let totalWidth = contentRect.size.width
        let totalHeight = contentRect.size.height
        
        let spanCount: CGFloat = 5
        
        let spanSize = totalHeight / spanCount
        let viewHeight: CGFloat = 10
        let topOffset = spanSize * 2 - viewHeight/2
        
        
        let barRect: CGRect = CGRect(x: -6, y: topOffset, width: totalWidth * 2, height: viewHeight)
        
        let bar = UIView(frame: barRect)
        bar.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        overlay.addSubview(bar)
        
        let customText = UITextView(frame:CGRect(x: 20, y: -10, width: 100, height: 30))
        
        customText.text = "Custom Goal"
        customText.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        bar.addSubview(customText)
        
        self.updateLinePosition()
        
        self.lineView = bar
        
        
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        let yRange = 50
        
        self.setDataCount(Int(sliderX.value) + 1, range: UInt32(yRange))
    }
    
    
    func updateLinePosition() {
        
        let contentRect = chartView.contentRect
        
        let totalWidth = contentRect.size.width
        let totalHeight = contentRect.size.height
        
        let spanCount: CGFloat = 5
        
        let spanSize = totalHeight / spanCount
        let viewHeight: CGFloat = 10
        let topOffset = spanSize * CGFloat(5 - Int(self.sliderY.value)) - viewHeight/2
        
        let barRect: CGRect = CGRect(x: -6, y: topOffset, width: totalWidth * 2, height: viewHeight)
        self.lineView?.frame = barRect
        
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let start = 1
        
        let yVals = (start..<start+count+1).map { (i) -> BarChartDataEntry in
            
            if i == 2 {
                return BarChartDataEntry(x: Double(i), y: 50)
            }
            
            let mult = range + 1
            let val = Double(arc4random_uniform(mult))
            if arc4random_uniform(100) < 25 {
                return BarChartDataEntry(x: Double(i), y: val, icon: UIImage(named: "icon"))
            } else {
                return BarChartDataEntry(x: Double(i), y: val)
            }
        }
        
        var set1: BarChartDataSet! = nil
        if let set = chartView.data?.first as? BarChartDataSet {
            set1 = set
            set1.replaceEntries(yVals)
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(entries: yVals, label: "The year 2017")
            set1.colors = ChartColorTemplates.material()
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.9
            chartView.data = data
        }
        
//        chartView.setNeedsDisplay()
    }
    
    override func optionTapped(_ option: Option) {
        super.handleOption(option, forChartView: chartView)
    }
    
    // MARK: - Actions
    @IBAction func slidersValueChanged(_ sender: Any?) {
        sliderTextX.text = "\(Int(sliderX.value + 2))"
        sliderTextY.text = "\(Int(sliderY.value))"
        
        if sender as? UISlider == sliderY {
            self.updateLinePosition()
        } else {
            self.updateChartData()
        }
        
    }
}
