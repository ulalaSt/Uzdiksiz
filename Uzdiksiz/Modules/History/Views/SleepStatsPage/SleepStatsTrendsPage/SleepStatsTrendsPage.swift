//
//  SleepStatsTrendsPage.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 08.09.2025.
//

import SwiftUI

struct SleepStatsTrendsPage: View {
    @Environment(\.dismiss) var dismiss
    @State var currentState: SleepStatsState = .weekly
    @Namespace var namespace
    let viewModel: SleepReportViewModel
    
    init(viewModel: SleepReportViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 24) {
            selector
                .padding(.top, 12)
            TabView(selection: $currentState) {
                SleepStatsTrendsListView(state: .weekly, reportViewModel: viewModel)
                    .tag(SleepStatsState.weekly)
                SleepStatsTrendsListView(state: .monthly, reportViewModel: viewModel)
                    .tag(SleepStatsState.monthly)
                SleepStatsTrendsListView(state: .custom, reportViewModel: viewModel)
                    .tag(SleepStatsState.custom)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .toolbar(.hidden, for: .tabBar)
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
            let states = Array(SleepStatsState.allCases.enumerated())
            ForEach(states, id: \.offset) { (index, state) in
                let isActive = currentState == state
                if !isActive, let prev = states.first(where: { $0.0 == index-1}), currentState != prev.1 {
                    Rectangle().fill(Color.white.opacity(0.1)).frame(width: 1, height: 16)
                }
                Text(state.title)
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
                            currentState = state
                        }
                    }
            }
        }
        .background(Capsule().fill(.white.opacity(0.1)))
    }
}

enum SleepStatsState: Int, Equatable, CaseIterable, Identifiable {
    var id: Self { self }
    case weekly
    case monthly
    case custom
    
    var title: String {
        switch self {
        case .weekly:
            "Апта"
        case .monthly:
            "Ай"
        case .custom:
            "Басқа"
        }
    }
}
