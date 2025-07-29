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
        VStack(spacing: 20) {
            
            if let email = authViewModel.user?.email {
                Text("📧 \(email)")
                    .font(.title3)
            }

            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            if let location = locationManager.location {
                Text("Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)")
            } else {
                Text("Getting location...")
            }
            VStack(spacing: 20) {
                Text("🌅 Sunrise: \(sunrise)")
                Text("🌇 Sunset: \(sunset)")
            }
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
            .padding()

            Button("Log Out") {
                authViewModel.signOut()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Delete Account") {
                showConfirmDelete = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .alert("Are you sure you want to delete your account?", isPresented: $showConfirmDelete) {
            Button("Delete", role: .destructive) {
                isDeleting = true
                authViewModel.deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        }
        .disabled(authViewModel.isLoading || isDeleting)
        .opacity((authViewModel.isLoading || isDeleting) ? 0.5 : 1)
    }
}
