//
//  MapViewController.swift
//  ZaHunter
//
//  Created by Wong You Jing on 04/02/2016.
//  Copyright © 2016 NoNonsense. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    var pizzaPlaces = [PizzaPlace]()
    var userLocation = CLLocation()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPizzaPlacesToMap()
        self.zoomToFitAnnotations()
    }
    
    func addPizzaPlacesToMap() {
        for pizzaPlace in self.pizzaPlaces {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pizzaPlace.location.coordinate
            annotation.title = pizzaPlace.name
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func zoomToFitAnnotations() {
        var region = MKCoordinateRegionMakeWithDistance(self.userLocation.coordinate, 10000, 10000)
        
        region = self.mapView.regionThatFits(region)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.image = UIImage(named: "pizza.png")
        pin.canShowCallout = true
        pin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotation = view.annotation
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewControllerWithIdentifier("routeVC") as! RouteViewController
        destinationVC.destinationCoordinate = annotation!.coordinate
        destinationVC.sourceCoordinate = self.userLocation.coordinate
        navigationController?.pushViewController(destinationVC, animated: true)
    }

    
    

}
