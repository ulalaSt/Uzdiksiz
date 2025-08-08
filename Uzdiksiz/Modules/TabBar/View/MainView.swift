//
//  MainView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 14.07.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject var sleepLogViewModel = SleepLogViewModel()
    @StateObject var locationManager = LocationManager()
    @ObservedObject var authViewModel: AuthViewModel
    @State private var sunrise: Date? = nil
    @State private var sunset: Date? = nil
    @State private var selectedTab = TabState.home

    var body: some View {
        switch sleepLogViewModel.expectedWakeTime {
        case .notRequested:
            Text("")
                .onAppear {
                    sleepLogViewModel.fetchExpectedWakeTime()
                }
        case .isLoading(let last, let cancelBag):
            ProgressView("Мақсатты ояну уақыты жүктелуде...")
        case .loaded(let t):
            if t == nil {
                TargetWakeTimeCreationView(viewModel: sleepLogViewModel)
            } else {
                content
            }
        case .failed(let aPIError):
            Text(aPIError.errorDescription)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red)
        }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                TodayView(viewModel: sleepLogViewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .tag(TabState.home)
                SleepHistoryView(viewModel: sleepLogViewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(TabState.history)
                ProfileView(authViewModel: authViewModel, locationManager: locationManager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(TabState.profile)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.all)
            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(
            bgView
        )
        .onReceive(locationManager.$location.compactMap { $0 }) { location in
            let (rise, set) = locationManager.getSunriseSunsetStrings(for: location)
            self.sunrise = rise
            self.sunset = set
        }
    }
    
    var bgView: some View {
        Image("night_bg")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

