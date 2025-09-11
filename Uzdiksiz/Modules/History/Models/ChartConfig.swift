//
//  ChartConfig.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 10.09.2025.
//
import Charts
import Foundation

struct AxisConfig<Value: Hashable & Plottable> {
    var label: String?
    var values: [Value]? = nil
    var format: (Value) -> String
    var labelScale: ((Int, Int) -> [Int])?
    var labelValue: ((Value) -> PlottableValue<Value>)?
}

struct ChartConfig<X: Hashable & Plottable> {
    var xAxis: AxisConfig<X>
    var yAxis: AxisConfig<Int>
    var showAverage: Bool = true
    var selectionConfig: ChartSelection<X, Int>
}

