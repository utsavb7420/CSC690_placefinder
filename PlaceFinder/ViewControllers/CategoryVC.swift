//
//  CategoryVC.swift
//  PlaceFinder


import UIKit

class CategoryVC: UIViewController, LoadingIndicatorDelegate {
    
    // MARK: - Outlets

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view6: UIView!
    
    // MARK: - Variables
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setupUI()
    }
    
    func setupUI() {
        [view1, view2, view3, view4, view5, view6].forEach { (backView) in
            backView?.layer.cornerRadius = 6.0
            backView?.layer.borderWidth = 1.0
            backView?.layer.borderColor = UIColor.systemTeal.cgColor
        }
    }
    @IBAction func pressedBanks(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PlacesTVC") as! PlacesTVC
        vc.selectedType = "bank"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pressedHospitals(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PlacesTVC") as! PlacesTVC
        vc.selectedType = "hospital"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pressedRestaurants(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PlacesTVC") as! PlacesTVC
        vc.selectedType = "restaurant"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func pressedShopping(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PlacesTVC") as! PlacesTVC
        vc.selectedType = "shopping_mall"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pressedMovies(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PlacesTVC") as! PlacesTVC
        vc.selectedType = "movie_theater"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pressedGasStations(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PlacesTVC") as! PlacesTVC
        vc.selectedType = "gas_station"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
