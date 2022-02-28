//
//  ViewController.swift
//  hcdemo
//
//  Created by Yu Wang on 2022/1/5.
//

import UIKit
import Highcharts
import WebKit

class ViewController: UIViewController, HIChartViewDelegate {
    
    internal var chartView: HIChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chartView = HIChartView(frame: CGRect(x: view.bounds.minX,
                                                  y: view.bounds.minY,
                                                  width: view.bounds.width,
                                                  height: view.bounds.height - 100))
        chartView.options = options
        chartView.plugins = Constants.plugins
        view.addSubview(chartView)
    }
    
    func chartViewDidLoad(_ chart: HIChartView!) {}
    
}


extension ViewController {
    internal enum Constants {
        static let chartType = "column"
        static let plugins = ["annotations"]
        static let yAxisGridLineDashStyle = "Dash"
        static let curveSeriesType = "line"
        static let xAxisCategory = ["Jan", "Feb", "Mar", "Apr", "May", "June"]
        // FIXME: if curveData is much greater than series data blow (eg. 200), curve line will not appear on the garph. BUT if the curve line are using a solid color(eg. red) instead of gradient color, curve line will display correctly regardless of the value. Check another FIXME tag blow
        static let curveData = Array(repeating: 199, count: 6) // change to 200, grandient curve line will disappear
        static let seriesAData = Array(repeating: 100, count: 6)
        static let seriesBData = Array(repeating: 100, count: 6)
    }
    
    var options: HIOptions {
        let options = HIOptions()
        options.chart = chart
        options.title = hiTitle
        options.xAxis = [xAxis]
        options.yAxis = [yAxis]
        options.tooltip = tooltip
        options.series = series
        options.plotOptions = plotOptions
        options.credits = credit
        options.exporting = exporting
        return options
    }
    
    var plugins: [String] { Constants.plugins }
    
    internal var chart: HIChart {
        let chart = HIChart()
        chart.backgroundColor = HIColor(uiColor: UIColor.white)
        chart.type = Constants.chartType
        chart.events = {
            let chartEvent = HIEvents()
            chartEvent.load = HIFunction(jsFunction:
                                            """
                function() {
                    var axis = this.xAxis[0];
                    var ticks = axis.ticks;
                    var points = this.series[0].points;
                    var data = this.series[0].data;
                    data[data.length - 1].firePointEvent('click');
                    points.forEach(function(point, i) {
                        if (ticks[i]) {
                            var label = ticks[i].label.element;
                            label.onclick = function() {
                            data[i].firePointEvent('click');
                            }
                        }
                    });
                }
                """.replacingOccurrences(of: "\n", with: ""))
            return chartEvent
        }()
        return chart
    }
    
    internal var hiTitle: HITitle {
        let title = HITitle()
        title.text = ""
        return title
    }
    
    internal var xAxis: HIXAxis {
        let xAxis = HIXAxis()
        xAxis.labels = {
            let label = HILabels()
            label.style = {
                let style = HICSSObject()
                style.color = UIColor.gray.hexStr!
                style.fontSize = "14"
                return style
            }()
            return label
        }()
        xAxis.lineColor = HIColor(uiColor: UIColor.gray)
        xAxis.categories = Constants.xAxisCategory
        
        return xAxis
    }
    
    internal var yAxis: HIYAxis {
        let yAxis = HIYAxis()
        yAxis.title = {
            let title = HITitle()
            title.text = ""
            return title
        }()
        yAxis.labels = {
            let label = HILabels()
            label.enabled = false
            return label
        }()
        yAxis.gridLineDashStyle = Constants.yAxisGridLineDashStyle
        yAxis.gridLineColor = HIColor(uiColor: UIColor.gray)
        return yAxis
    }
    
    internal var tooltip: HITooltip {
        let tooltip = HITooltip()
        tooltip.enabled = false
        return tooltip
    }
    
    internal var series: [HISeries] {
        let columnASeries = HISeries()
        columnASeries.name = "ColumnA"
        columnASeries.color = HIColor(uiColor: UIColor.lightGray)
        columnASeries.showInLegend = false
        columnASeries.states = {
            let states = HIStates()
            states.select = {
                let select = HISelect()
                select.color = HIColor(uiColor: UIColor.green)
                return select
            }()
            return states
        }()
        columnASeries.data = Constants.seriesAData
        
        let columnBSeries = HISeries()
        columnBSeries.name = "ColumnB"
        columnBSeries.color = HIColor(uiColor: UIColor.gray)
        columnBSeries.showInLegend = false
        columnBSeries.states = {
            let states = HIStates()
            states.select = {
                let select = HISelect()
                select.color = HIColor(uiColor: UIColor.blue)
                return select
            }()
            return states
        }()
        columnBSeries.data = Constants.seriesBData
        
        let curveLineSeries = HISeries()
        curveLineSeries.visible = true
        curveLineSeries.type = Constants.curveSeriesType
        curveLineSeries.name = "Curve"
        curveLineSeries.color = HIColor(uiColor: UIColor.clear)
        curveLineSeries.data = Constants.curveData
        curveLineSeries.showInLegend = false
        
        return [columnASeries, columnBSeries, curveLineSeries]
    }
    
    internal var credit: HICredits {
        let credits = HICredits()
        credits.enabled = false
        return credits
    }
    
    internal var exporting: HIExporting {
        let exporting = HIExporting()
        exporting.enabled = false
        return exporting
    }
    
    internal var plotOptions: HIPlotOptions {
        let plotOptions = HIPlotOptions()
        plotOptions.column = {
            let column = HIColumn()
            column.showInLegend = false
            column.borderWidth = 0
            column.borderRadius = 4
            return column
        }()
        plotOptions.series = {
            let series = HISeries()
            series.states = {
                let states = HIStates()
                let inactive = HIInactive()
                inactive.opacity = 1
                states.inactive = inactive
                return states
            }()
            series.stickyTracking = false
            series.allowPointSelect = true
            series.point = {
                let point = HIPoint()
                let events = HIEvents()
                events.click = onSeriesClick
                point.events = events
                return point
            }()
            return series
        }()
        return plotOptions
    }
    
    internal var onSeriesClick: HIFunction {
        let curveLabelColorHex = UIColor.gray.hexStr!
        let blueColorHex = UIColor.blue.hexStr!
        let blueLightColorHex = UIColor.blue.withAlphaComponent(0.5).hexStr!
        let blueLighterColorHex = UIColor.blue.withAlphaComponent(0.3).hexStr!
        let blueLightestColorHex = UIColor.blue.withAlphaComponent(0.2).hexStr!
        let curveLabelText = "Curve"
        
        let curvesStr = "['\(Constants.curveData.map { $0 > 0 ? "\($0)" : "" }.joined(separator: "','"))']"
        
        let onTap: HIClosure = { context in
            guard let category = context?.getProperty("this.category").flatMap({ $0 as? String }),
                  category.isEmpty == false
            else {
                return
            }
            print("onCategoryTap: ", category)
        }
        // FIXME:  Line 341. when using a solid color, the curve will apear on the graph always regardless of the series data. but when using gradient color, the curve line will display when series data is smaller than some specific value.
        return HIFunction(
            closure: onTap,
            jsFunction:
                """
            function () {
                const colors = {
                  curveLabelColor: '\(curveLabelColorHex)',
                  blueDefault: '\(blueColorHex)',
                  blueLight: '\(blueLightColorHex)',
                  blueLighter: '\(blueLighterColorHex)',
                  blueLightest: '\(blueLightestColorHex)',
                };

                const generatecurveLine = (
                  curveData,
                  selectedIndex
                ) => {
                  const curveLine = [];
                  let curveLinePoints = [];

                  curveData.forEach((curve, index) => {
                    if (curve === undefined) {
                      curveLine.push({
                        points: curveLinePoints,
                        stroke:
                          index <= selectedIndex
                            ? colors.blueDefault
                            : colors.blueLighter,
                      });
                      curveLinePoints = [];
                    } else {
                      const precurve = curveData[index - 1];
                      const nextcurve = curveData[index + 1];
                      const halfStep = 0.5;

                      if (precurve === undefined) {
                        curveLinePoints.push({
                          x: index - halfStep,
                          y: curve,
                          xAxis: 0,
                          yAxis: 0,
                        });
                      }

                      curveLinePoints.push({ x: index, y: curve, xAxis: 0, yAxis: 0 });

                      curveLinePoints.push({
                        ...(nextcurve === undefined
                          ? { x: index + halfStep, y: curve }
                          : { x: index + 1, y: nextcurve }),
                        xAxis: 0,
                        yAxis: 0,
                      });
                    }
                  });

                  curveLine.push({ points: curveLinePoints });
                  return curveLine;
                };

                const generatecurveLineWithGradient = (
                  curveLine,
                  selectedIndex
                ) => {
                  return curveLine.map((curveLinePoint) => {
                    const xPoints = curveLinePoint.points.map((point) => point.x);
                    const maxPointX = Math.max(
                      ...xPoints,
                      0
                    );
                    const minPointX = Math.min(
                      ...xPoints,
                      maxPointX
                    );
                    const selectedCurve =
                      selectedIndex <= maxPointX && selectedIndex >= minPointX;

                    const gradientColor = {
                      linearGradient: { x1: 0, y1: 0, x2: 1, y2: 0 },
                      stops: [
                        [0, colors.blueLightest],
                        [
                          (selectedIndex - 0.5 - minPointX) / (maxPointX - minPointX),
                          colors.blueLight,
                        ],
                        [
                          (selectedIndex - minPointX) / (maxPointX - minPointX),
                          colors.blueDefault,
                        ],
                        [
                          (selectedIndex + 0.5 - minPointX) / (maxPointX - minPointX),
                          colors.blueLightest,
                        ],
                        [1, colors.blueLighter],
                      ],
                    };
                    return {
                      points: curveLinePoint.points,
                      stroke: selectedCurve ? gradientColor : colors.blueLighter,
                    };
                  });
                };

                const getcurveLabelPoint = (curveData) => {
                  const nonEmptycurves = curveData.filter((curve) => curve);
                  const curveLabelPoint = {
                    x: 0,
                    y: nonEmptycurves[0],
                    xAxis: 0,
                    yAxis: 0,
                  };
                  return curveLabelPoint;
                };

                const curveLineDisplay = (
                  selectedIndex,
                  curves
                ) => {
                  const curveData = curves.data.map((curve) =>
                    curve === '' ? undefined : curve
                  );

                  const curveLine = generatecurveLine(
                    curveData,
                    selectedIndex
                  );

                  const curveLineWithGradient = generatecurveLineWithGradient(
                    curveLine,
                    selectedIndex
                  );

                  const curveLabelPoint = getcurveLabelPoint(curveData);

                  const curveLabel = {
                    point: curveLabelPoint,
                    format: curves.text,
                    shadow: false,
                    height: 20,
                    backgroundColor: 'transparent',
                    borderWidth: 0,
                    padding: -14,
                    className: 'curve-label',
                    style: {
                      color: colors.blueDefault,
                      fontSize: '12px',
                      lineHeight: '14px',
                      textShadow: `1px 1px 0px ${colors.curveLabelColor}, -1px 1px 0px ${colors.curveLabelColor}, 1px -1px 0px ${colors.curveLabelColor}, -1px -1px 0px ${colors.curveLabelColor}`,
                    },
                  };

                  return { curveLabel, curveLineWithGradient };
                };

                var clickedPoint = this;
                var index = this.x;
                setTimeout(function() {
                    var chart = clickedPoint.series.chart;
                    var columnASerie = chart.series[0].data[index];
                    var columnBSerie = chart.series[1].data[index];
                    var columnA = columnASerie.y;
                    var columnB = columnBSerie.y;
                    var y = columnA > columnB ? columnA : columnB;
                    columnASerie.select(true, true);
                    columnBSerie.select(true, true);

                    const { curveLabel, curveLineWithGradient } = curveLineDisplay(
                        index,
                        { data: \(curvesStr), text: '\(curveLabelText)' }
                    );

                    var newAnnotation = {
                        id: 'annotation',
                        labels: [{ point: { x: index, y: y, xAxis: 0, yAxis: 0 } }, curveLabel ],
                        crop: false,
                        shapes: curveLineWithGradient,
                        shapeOptions: {
                            fill: 'none',
                            strokeWidth: 4,
                            type: 'path',
                        },
                        draggable: '',
                    };
                    chart.removeAnnotation('annotation');
                    chart.addAnnotation(newAnnotation);
                }, 0);
            }
            """.replacingOccurrences(of: "\n", with: ""),
            properties: ["this.category"]
        )
    }
    
}


// MARK: - UIColor -> Hex String

extension UIColor {
    var hexStr: String? {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0

            let multiplier = CGFloat(255.999999)

            guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
                return nil
            }

            if alpha == 1.0 {
                return String(
                    format: "#%02lX%02lX%02lX",
                    Int(red * multiplier),
                    Int(green * multiplier),
                    Int(blue * multiplier)
                )
            }
            else {
                return String(
                    format: "#%02lX%02lX%02lX%02lX",
                    Int(red * multiplier),
                    Int(green * multiplier),
                    Int(blue * multiplier),
                    Int(alpha * multiplier)
                )
            }
        }
}
