//
//  LocationHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 12/26/17.
//

import Foundation
import CoreLocation

public class LocationHelper: NSObject {
    public static var shared = LocationHelper()
    
    public enum Result {
        case success(loc: CLLocation),
        failed(error: Error, authStatus: CLAuthorizationStatus)
    }
    
    public typealias ResultCallback = ((Result) -> ())
    
    public var isEnabled: Bool {
        get {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            default:
                return false
            }
        }
    }
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        return locationManager
    }()
    
    var callback: ResultCallback?
    
    public func update(completion: @escaping ResultCallback) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        callback = completion
    }
}

extension LocationHelper: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        callback?(.success(loc: loc))
        callback = nil
        manager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        callback?(.failed(error: error, authStatus: CLLocationManager.authorizationStatus()))
        callback = nil
    }
}
