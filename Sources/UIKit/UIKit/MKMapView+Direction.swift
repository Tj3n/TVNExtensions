//
//  MKMapView+Direction.swift
//  TVNExtensions
//
//  Created by Vũ Tiến on 4/17/20.
//

import Foundation
import MapKit
import TVNExtensionsFoundation

//MARK: - Routing
protocol MapViewDirectionable: AnyObject where Self: CLLocationManagerDelegate {
    var mapView: MKMapView { get }
    var steps: [MKRoute.Step] { get set }
    var stepCounter: Int { get set }
    var manager: CLLocationManager { get }
}

extension MapViewDirectionable {
    /// Override to check if user is ok to start navigate
    /// - Parameter coordinate: CLLocationCoordinate2D
    func isDirectionAvailable(to coordinate: CLLocationCoordinate2D) -> Bool {
        return true
    }
    
    func showDirection(to annotation: MKAnnotation, errorHandler: ((Error?)->())?) {
        showDirection(to: annotation.coordinate, errorHandler: errorHandler)
    }
    
    func showDirection(to coordinate: CLLocationCoordinate2D, errorHandler: ((Error?)->())?) {
        guard isDirectionAvailable(to: coordinate) else {
            errorHandler?(NSError(domain: TVNErrorDomain, code: 500, userInfo: [NSLocalizedDescriptionKey: "Direction not available to coordinate \(coordinate)"]))
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response,
                let route = unwrappedResponse.routes.first else {
                    errorHandler?(error)
                    UILabel.showTooltip("Routing to this place is not available from your location.")
                    return
            }
            
            self.createRoute(from: route.steps)
        }
    }
    
    func createRoute(from steps: [MKRoute.Step]) {
        self.mapView.addOverlays(steps.map({ $0.polyline }))
        self.mapView.removeOverlays(self.steps.map({ $0.polyline }))
        self.steps = Array(steps.dropFirst())
        
        if let first = self.steps.first { //Zoomout map to route rect
            let rect = self.steps.reduce(first.polyline.boundingMapRect, { $0.union($1.polyline.boundingMapRect) })
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
            UILabel.showTooltip(first.instructions, duration: 15)
        }
        
        #if DEBUG
        self.steps.forEach({ step in
            let point = step.polyline.points()[step.polyline.pointCount - 1]
            let coor = MKMapPoint(x: point.x, y: point.y).coordinate
            print("Instruction ", step.instructions, coor, step.distance)
        })
        #endif
        
        stepCounter = 0
        manager.startUpdatingLocation()
    }
    
    /// Check if next touch point contains user location
    /// - Parameter userLocation: CLLocation
    func checkSteps(userLocation: CLLocation) -> Bool {
        guard steps.count > stepCounter else { return false }
        let currentStep = steps[stepCounter]
        let pointsArray = currentStep.polyline.points()
        let lastPoint = pointsArray[currentStep.polyline.pointCount - 1]
        let theLoc = MKMapPoint(x: lastPoint.x, y: lastPoint.y)
        let theRegion = CLCircularRegion(center: theLoc.coordinate, radius: 30, identifier: "touchPoint")
        return theRegion.contains(userLocation.coordinate)
    }
    
    @discardableResult
    func moveToNextStep() -> MKRoute.Step? {
        guard steps.count > stepCounter+1 else {
            removeCurrentDirection()
            return nil
        }
        let currentStep = steps[stepCounter]
        mapView.removeOverlay(currentStep.polyline)
        stepCounter += 1
        return steps[safe: stepCounter]
    }
    
    func removeCurrentDirection() {
        manager.stopUpdatingLocation()
        mapView.removeOverlays(self.steps.map({ $0.polyline }))
        steps.removeAll()
        stepCounter = 0
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !steps.isEmpty, let loc = locations.first else { return }
        if checkSteps(userLocation: loc) {
            if let nextStep = moveToNextStep() {
                UILabel.showTooltip(nextStep.instructions, duration: 15)
            }
        }
    }
}
