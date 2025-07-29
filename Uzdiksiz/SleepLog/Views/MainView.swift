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
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                TodayView(viewModel: sleepLogViewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(0)
                ProfileView(authViewModel: authViewModel, locationManager: locationManager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(1)
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
