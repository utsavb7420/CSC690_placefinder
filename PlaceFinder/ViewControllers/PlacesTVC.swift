//
//  PlacesTVC.swift
//  PlaceFinder


import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import GooglePlaces
import GoogleMaps

class PlacesTVC: UITableViewController, LoadingIndicatorDelegate {
    
    // MARK: - Variables
    let locationManager = CLLocationManager()
    var selectedType: String?
    var userLocation: CLLocation?
    var placesArr: [PlaceModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startLoading()
        setupLocationDlegate()
    }
    
    func setupLocationDlegate() {
        //spør for "authorisation" fra brukeren
        self.locationManager.requestWhenInUseAuthorization()
        
        //for bruk i "foreground"
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return placesArr.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = placesArr[indexPath.row].name
        cell.detailTextLabel?.text = placesArr[indexPath.row].address
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewVC") as! MapViewVC
        vc.selectedPin = placesArr[indexPath.row].location
        vc.placeModel = placesArr[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
extension PlacesTVC: CLLocationManagerDelegate {
    // MARK: - Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location)
            userLocation = location
            getPlacesFromGoogleAPI()
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
extension PlacesTVC {
    func getPlacesFromGoogleAPI() {
        
        if let selectedPlaceType = selectedType {
            // MARK: Create URL
            let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(userLocation!.coordinate.latitude),\(userLocation!.coordinate.longitude)&radius=3000&type=\(selectedPlaceType)&key=AIzaSyDPFNkF6KRwJXoaASrr5o_KYH-lrdo1qFY"
            
            print(url)
            
            // MARK: Request for response from the google
            AF.request(url).responseJSON { [self] (reseponse) in
                guard let data = reseponse.data else {
                    return
                }
                
                do {
                    let jsonData = try JSON(data: data)
                    let places = jsonData["results"].arrayValue
                    self.placesArr = []
                    for place in places {
                        let geo = place["geometry"]
                        let location = geo["location"]
                        let name = place["name"].string
                        let icon = place["icon"].string
                        let address = place["vicinity"].string
                        let rating = place["rating"].double
                        let lat = (location["lat"]).double
                        let lon = (location["lng"]).double
                        
                        let placeModel = PlaceModel(name: name ?? "", icon: icon ?? "", location: CLLocation(latitude: lat ?? 0.0, longitude: lon ?? 0.0), rating: rating ?? 0.0, address: address ?? "")
                        
                        placesArr.append(placeModel)
                    }
                    self.stopLoading()
                    tableView.reloadData()
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct PlaceModel {
    var name: String
    var icon: String
    var location: CLLocation?
    var rating: Double
    var address: String
    
    init(name: String, icon: String, location: CLLocation, rating: Double, address: String) {
        self.name = name
        self.icon = icon
        self.location = location
        self.rating = rating
        self.address = address
    }
}
