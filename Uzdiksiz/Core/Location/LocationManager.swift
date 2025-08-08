//
//  LocationManager.swift
//  Uzdiksiz
//
//  Created by Ulan Seitkali on 15.07.2025.
//

import CoreLocation
import Combine
import Solar

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if location == nil {
            location = locations.last
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func getSunriseSunsetStrings(for location: CLLocation) -> (Date?, Date?) {
        guard let now = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) else {
            return (nil, nil)
        }
        let solar = Solar(for: now, coordinate: location.coordinate)
        return (solar?.sunrise, solar?.sunset)
    }
}
