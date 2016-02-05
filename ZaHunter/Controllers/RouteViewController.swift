//
//  RouteViewController.swift
//  ZaHunter
//
//  Created by Wong You Jing on 04/02/2016.
//  Copyright © 2016 NoNonsense. All rights reserved.
//

import UIKit
import MapKit

class RouteViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var sourceCoordinate     = CLLocationCoordinate2D()
    var destinationCoordinate = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
        addCoordinatesToMap()
        addRoute()
        zoomToFitAnnotations()
    }
    
    func zoomToFitAnnotations() {
        var region = MKCoordinateRegionMakeWithDistance(sourceCoordinate, 10000, 10000)
        
        region = self.mapView.regionThatFits(region)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func addCoordinatesToMap() {
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.coordinate = sourceCoordinate
        self.mapView.addAnnotation(sourceAnnotation)
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationCoordinate
        self.mapView.addAnnotation(destinationAnnotation)
    }

    func addRoute() {
        let sourceMapItem = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinate, addressDictionary: nil))
        let destinationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
        
        let request = MKDirectionsRequest()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            if let routes = response?.routes{
                for route in routes{
                    self.mapView.addOverlay(route.polyline)
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKindOfClass(MKPolyline) {
            // draw the track
            let polyLine = overlay
            let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
            polyLineRenderer.strokeColor = UIColor.blueColor()
            polyLineRenderer.lineWidth = 2.0
            
            return polyLineRenderer
        }
        return MKPolylineRenderer()
    }
}
