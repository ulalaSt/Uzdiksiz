//
//  ChartData.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 10.09.2025.
//
import Charts
import Foundation

enum ChartType {
    case line
    case bar
}

struct ChartPoint<X: Hashable & Plottable> {
    let x: X
    let y: Int?
    let yStart: Int?
}

struct ChartData<X: Hashable & Plottable> {
    let type: ChartType
    let points: [ChartPoint<X>]
    let avgY: Int?
    let avgYStart: Int?
    
    init(type: ChartType, points: [ChartPoint<X>], avgY: Int? = nil, avgYStart: Int? = nil) {
        self.type = type
        self.points = points
        let vals = points.compactMap { $0.y }
        let valsStart = points.compactMap { $0.y }
        if avgY == nil, !vals.isEmpty {
            self.avgY = Int(Double(vals.reduce(0, +)) / Double(vals.count))
        } else {
            self.avgY = avgY
        }
        if avgYStart == nil, !valsStart.isEmpty {
            self.avgYStart =  Int(Double(valsStart.reduce(0, +)) / Double(valsStart.count))
        } else {
            self.avgYStart = avgYStart
        }
    }
    
    var minY: Int? {
        points.compactMap { $0.y }.min()
    }
    
    var maxY: Int? {
        points.compactMap { $0.y }.max()
    }
}
