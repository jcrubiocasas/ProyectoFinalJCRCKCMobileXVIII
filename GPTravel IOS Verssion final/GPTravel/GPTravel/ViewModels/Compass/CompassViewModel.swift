import Foundation
import CoreLocation
import CoreMotion
import SwiftUI

@MainActor
class CompassViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)
    @Published var heading: Double = 0.0
    private var destination: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdates(to destination: CLLocationCoordinate2D) {
        self.destination = destination
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func stopUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
    }

    var bearing: Double {
        guard let destination = destination else { return 0.0 }
        return bearingToDestination(from: currentLocation, to: destination) - heading
    }

    var distance: Double {
        guard let destination = destination else { return 0.0 }
        let loc1 = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let loc2 = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return loc1.distance(from: loc2)
    }

    private func bearingToDestination(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude.toRadians()
        let lon1 = from.longitude.toRadians()
        let lat2 = to.latitude.toRadians()
        let lon2 = to.longitude.toRadians()

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let initialBearing = atan2(y, x).toDegrees()
        return (initialBearing + 360).truncatingRemainder(dividingBy: 360)
    }
}

private extension Double {
    func toRadians() -> Double { self * .pi / 180 }
    func toDegrees() -> Double { self * 180 / .pi }
}
