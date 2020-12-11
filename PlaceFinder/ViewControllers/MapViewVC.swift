//
//  MapViewVC.swift
//  PlaceFinder


import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Alamofire
import SwiftyJSON

class MapViewVC: UIViewController, LoadingIndicatorDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Variables
    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController? = nil
//    var selectedPin: GMSPlace?
    var userLocation: CLLocation?
    var selectedPin: CLLocation?
    var placeModel: PlaceModel?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startLoading()
        setupLocationDlegate()
        setupMap()
        setupUI()
    }
    
    // MARK: - Actions
    
    @IBAction func pressedSearch(_ sender: Any) {
        setupSearchController()
    }
    
    // MARK: - Functions
    func setupMap() {
        mapView.isMyLocationEnabled = true
        
        locationView.layer.cornerRadius = 6.0
    }
    
    func setupLocationDlegate() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func setupSearchController() {
        let LocationSearchTV = GMSAutocompleteViewController()
        LocationSearchTV.delegate = self
        present(LocationSearchTV, animated: true, completion: nil)
    }
    
    func setupUI() {
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        locationView.isHidden = true
    }
    
    func dropPinZoomIn() {
        // remove markers
        mapView.clear()
        //        let camera = GMSCameraPosition(latitude: selectedPin?.coordinate.latitude ?? 0.0, longitude: selectedPin?.coordinate.longitude ?? 0.0, zoom: 17, bearing: .greatestFiniteMagnitude, viewingAngle: 0.0)
        //        mapView.animate(to: camera)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: selectedPin?.coordinate.latitude ?? 0.0, longitude: selectedPin?.coordinate.longitude ?? 0.0)
        marker.map = mapView
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setupBounds()
            self.setupRouteInfo()
        }
        
    }
    
    func setupBounds() {
        let bounds = GMSCoordinateBounds.init(coordinate: selectedPin!.coordinate, coordinate: userLocation!.coordinate)
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
    }
    
    func setupRouteInfo() {
        // MARK: Create source location and destination location so that you can pass it to the URL
        let sourceLocation = "\(userLocation!.coordinate.latitude),\(userLocation!.coordinate.longitude)"
        let destinationLocation = "\(selectedPin!.coordinate.latitude),\(selectedPin!.coordinate.longitude)"
        
        // MARK: Create URL
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceLocation)&destination=\(destinationLocation)&mode=driving&key=AIzaSyDPFNkF6KRwJXoaASrr5o_KYH-lrdo1qFY"
        
        // MARK: Request for response from the google
        AF.request(url).responseJSON { (reseponse) in
            guard let data = reseponse.data else {
                return
            }
            
            do {
                let jsonData = try JSON(data: data)
                let routes = jsonData["routes"].arrayValue
                
                for route in routes {
                    let overview_polyline = route["overview_polyline"].dictionary
                    let points = overview_polyline?["points"]?.string
                    let path = GMSPath.init(fromEncodedPath: points ?? "")
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeColor = .systemBlue
                    polyline.strokeWidth = 5
                    polyline.map = self.mapView
                }
                // set address
                self.addressLabel.text = self.placeModel?.address
                self.nameLabel.text = self.placeModel?.name
                
                self.locationView.isHidden = false
                self.stopLoading()
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
}
extension MapViewVC: CLLocationManagerDelegate {
    // MARK: - Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location)
            if userLocation == nil {
                userLocation = location
                let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 17.0)
                
                self.mapView?.animate(to: camera)
                self.locationManager.stopUpdatingLocation()
                self.dropPinZoomIn()
            }
           
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension GMSAutocompleteViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        
    }
}
extension MapViewVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print(place.rating)
        print(place.userRatingsTotal)
//        selectedPin = place
        dropPinZoomIn()
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
