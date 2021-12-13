//
//  ShowSellerPointViewController.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 28.06.2021.
//

import UIKit
import FirebaseFirestore
import MapKit

class ShowSellerPointViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var phone : String?
    var x : Double?
    var y : Double?
    
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database.collection("users").whereField("phone", isEqualTo: phone!).getDocuments() { (querySnapshot, err) in
            if let aquerySnapshot = querySnapshot {
                aquerySnapshot.documents.forEach({ (document) in
                    self.x = document.data()["x"] as? Double
                    self.y = document.data()["y"] as? Double
                    self.constraitingCamera()
                    self.setPoint()
                })
            }
            if self.x == nil {
                let alert = UIAlertController(title: "Ошибка", message: "Продавец не указал место для встречи!", preferredStyle: .alert)
                let action = UIAlertAction(title: "Да", style: .default) { (alertAction) in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setUpMap() {
        let staff = Staff(
            title: "Здесь находится продавец",
            coor: "Latitude: \(x!) Longitude: \(y!)",
            coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(x!), longitude: CLLocationDegrees(y!)))
        mapView.addAnnotation(staff)
    }
    
    func constraitingCamera() {
        let oahuCenter = CLLocation(latitude: CLLocationDegrees(x!), longitude: CLLocationDegrees(y!))
        let region = MKCoordinateRegion(
            center: oahuCenter.coordinate,
            latitudinalMeters: 50000,
            longitudinalMeters: 60000)
        mapView.setCameraBoundary(
            MKMapView.CameraBoundary(coordinateRegion: region),
            animated: true)
            
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    func setPoint() {
        let staff = Staff(
            title: "Точка для встречи",
            coor: "Latitude: \(x!) Longitude: \(y!)",
            coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(x!), longitude: CLLocationDegrees(y!)))
        mapView.addAnnotation(staff)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
