//
//  SleepStatsTrendsPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.09.2025.
//

import SwiftUI

struct SleepStatsTrendsPage: View {
    @Environment(\.dismiss) var dismiss
    @State var currentRange: SleepStatsRange = .weekly
    @Namespace var namespace
    let viewModel: SleepReportViewModel
    
    init(viewModel: SleepReportViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 24) {
            selector
                .padding(.top, 12)
            TabView(selection: $currentRange) {
                ForEach(SleepStatsRange.allCases) { range in
                    SleepStatsTrendsListView(range: range)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .padding(.horizontal, 24)
        .navigationBarHidden(false)
        .colorScheme(.dark)
        .navigationBarBackButtonHidden()
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                Text("Статистика")
                    .foregroundColor(.textSoftWhite)
                    .font(.headline.weight(.semibold))
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .frame(width: 44, height: 44)
                        .foregroundColor(.textSoftWhite)
                }
            }
        })
        .backgroundGradient(ignoring: .all)
    }
        
    var selector: some View {
        HStack(spacing: 0) {
            let ranges = Array(SleepStatsRange.allCases.enumerated())
            ForEach(ranges, id: \.offset) { (index, range) in
                let isActive = currentRange == range
                if !isActive, let prev = ranges.first(where: { $0.0 == index-1}), currentRange != prev.1 {
                    Rectangle().fill(Color.white.opacity(0.1)).frame(width: 1, height: 16)
                }
                Text(range.title)
                    .font(isActive ? .caption2.weight(.semibold) : .caption2)
                    .foregroundColor(.textSoftWhite)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .background {
                        if isActive {
                            Capsule()
                                .fill(Color.primaryOceanBlue)
                                .matchedGeometryEffect(id: "selector", in: namespace)
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            currentRange = range
                        }
                    }
            }
        }
        .background(Capsule().fill(.white.opacity(0.1)))
    }
}

enum SleepStatsRange: Int, Equatable, CaseIterable, Identifiable {
    var id: Self { self }
    case weekly
    case monthly
    case other
    
    var title: String {
        switch self {
        case .weekly:
            "Апта"
        case .monthly:
            "Ай"
        case .other:
            "Басқа"
        }
    }
}
