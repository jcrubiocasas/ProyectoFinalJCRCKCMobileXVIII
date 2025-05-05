//
//  LocationServiceProtocol.swift
//  GPTravel
//
//  Created by Juan Carlos Rubio Casas on 9/4/25.
//

import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol: ObservableObject {
    var currentLocation: CLLocationCoordinate2D? { get }
    func requestLocation()
}
