//
//  ProfileView.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 15.07.2025.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var locationManager: LocationManager
    @State private var isDeleting = false
    @State private var showConfirmDelete = false
    @State private var sunrise: String = "—"
    @State private var sunset: String = "—"

    var body: some View {
        VStack(spacing: 32) {
            Image("profile_placeholder")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            VStack(alignment: .leading, spacing: 16) {
                if let email = authViewModel.user?.email {
                    infoView("Email", desc: "📧 \(email)")
                }
                infoView("Күннің шығуы", desc: "🌅 \(sunrise)")
                infoView("Күннің батуы", desc: "🌇 \(sunset)")
            }
            
//            if let location = locationManager.location {
//                Text("Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)")
//            } else {
//                Text("Getting location...")
//            }
            
            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                authViewModel.signOut()
            } label: {
                HStack {
                    Text("Шығу")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(16)
                .background(BlurredBackgroundView())
            }

            Button {
                showConfirmDelete = true
            } label: {
                Text("Аккаунтты жою")
                    .foregroundColor(Color(red: 255 / 255, green: 78 / 255, blue: 78 / 255))
                    .font(.system(size: 18, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(BlurredBackgroundView())
            }
            
            Spacer()
        }
        .padding(16)
        .alert("Are you sure you want to delete your account?", isPresented: $showConfirmDelete) {
            Button("Delete", role: .destructive) {
                isDeleting = true
                authViewModel.deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        }
        .disabled(authViewModel.isLoading || isDeleting)
        .opacity((authViewModel.isLoading || isDeleting) ? 0.5 : 1)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Профиль")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onReceive(locationManager.$location.compactMap { $0 }) { location in
            let (rise, set) = locationManager.getSunriseSunsetStrings(for: location)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            formatter.timeZone = TimeZone.current

            let riseString = rise.map { formatter.string(from: $0) } ?? "?"
            let setString = set.map { formatter.string(from: $0) } ?? "?"

            sunrise = riseString
            sunset = setString
        }
    }
    
    func infoView(_ title: String, desc: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 205 / 255, green: 230 / 255, blue: 245 / 255))
            Text(desc)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(BlurredBackgroundView())
    }
}
