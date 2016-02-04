//
//  PizzaPlace.swift
//  ZaHunter
//
//  Created by Wong You Jing on 03/02/2016.
//  Copyright © 2016 NoNonsense. All rights reserved.
//

import UIKit
import MapKit

class PizzaPlace: NSObject {
    let name: String?
    let location: CLLocation
    let mapItem: MKMapItem
    
    init(mapItem: MKMapItem){
        name = mapItem.name
        location = mapItem.placemark.location!
        self.mapItem = mapItem
    }
    
    func distanceFromLocation(location: CLLocation) -> Double {
        return location.distanceFromLocation(self.location)
    }
    
    func travelTimeFromLocation(mapItem: MKMapItem, completionHandler: (timeInterval: NSTimeInterval) -> Void) {
        let request = MKDirectionsRequest()
        request.source = mapItem
        request.destination = self.mapItem
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            let routes = response?.routes
            let route = routes?.first
            completionHandler(timeInterval: route!.expectedTravelTime)
        }
    }
}
