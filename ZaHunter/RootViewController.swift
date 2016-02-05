//
//  RootViewController.swift
//  ZaHunter
//
//  Created by Wong You Jing on 03/02/2016.
//  Copyright © 2016 NoNonsense. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    var pizzaPlaces = [PizzaPlace]()
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var travelTime = 0
    var footerLabel = UILabel()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        let tableFooterView = UIView.init(frame: CGRectMake(0, 0, 320, 50))
        tableFooterView.backgroundColor = UIColor.blackColor()
        footerLabel = UILabel(frame: CGRectMake(10, 10, 320, 50))
        footerLabel.text = "\(travelTime)"
        footerLabel.textColor = UIColor.whiteColor()
        tableFooterView.addSubview(footerLabel)
        self.tableView.tableFooterView = tableFooterView

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.drawTableViewCells()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil) { (context) -> Void in
            self.drawTableViewCells()
        }
    }

    func drawTableViewCells() {
        self.tableView.rowHeight = self.tableView.frame.height / 5.0
        self.footerLabel.superview?.frame = CGRectMake(0, 0, 320, self.tableView.frame.height / 5)
        self.footerLabel.frame = CGRectMake(10, 10, 320, self.tableView.frame.height / 5)
        self.tableView.reloadData()
    }
    
    func searchForPizzaPlaces(){
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "Pizza"
        request.region = MKCoordinateRegionMakeWithDistance(self.userLocation.coordinate, 10000, 10000)
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) -> Void in
            let mapItems = response?.mapItems
            self.pizzaPlaces = (mapItems?.map({ PizzaPlace(mapItem: $0) }))!
            self.pizzaPlaces.sortInPlace({ (pizza1, pizza2) -> Bool in
                pizza1.distanceFromLocation(self.userLocation) < pizza2.distanceFromLocation(self.userLocation)
            })
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.calculateTime()
            })
        }
    }
    
    func calculateTime() {
        var currentLocation = MKMapItem.mapItemForCurrentLocation()
        self.footerLabel.text = "0"

        for pizzaPlace: PizzaPlace in self.pizzaPlaces[0 ..< 4]{
            pizzaPlace.travelTimeFromLocation(currentLocation, completionHandler: { (timeInterval) -> Void in
                self.travelTime += Int(timeInterval) + 3000
                self.footerLabel.text = "\(self.travelTime/60) minutes to za them all"
                
            })
            currentLocation = pizzaPlace.mapItem
        }
    }

    // MARK: - Table View Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pizzaPlaces.count < 4 ? pizzaPlaces.count : 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        let pizzaPlace = self.pizzaPlaces[indexPath.row]
        cell.textLabel?.text = pizzaPlace.name
        cell.detailTextLabel?.text = "\(pizzaPlace.distanceFromLocation(self.userLocation)) meters away."
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.pizzaPlaces.removeAtIndex(indexPath.row)
        self.tableView.reloadData()
    }
    
    // MARK: - Location Manager Delegates
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        if location?.verticalAccuracy < 1000 && location?.horizontalAccuracy < 1000 {
            locationManager.stopUpdatingLocation()
            self.userLocation = location!
            self.searchForPizzaPlaces()
        }
    }
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! MapViewController
        destination.pizzaPlaces = (self.pizzaPlaces.count > 4 ? Array(self.pizzaPlaces[0...3]) : self.pizzaPlaces)
        destination.userLocation = self.userLocation
    }
}
