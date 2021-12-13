//
//  SetLocationViewController.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 28.06.2021.
//

import UIKit
import MapKit
import FirebaseFirestore

class SetLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let database = Firestore.firestore()
    
    var x : Double?
    var y : Double?
    var docID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        database.collection("users").whereField("phone", isEqualTo: UserDefaults.standard.string(forKey: "phone")).getDocuments() { (querySnapshot, err) in
            if let aquerySnapshot = querySnapshot {
                aquerySnapshot.documents.forEach({ (document) in
                    self.x = document.data()["x"] as? Double
                    self.y = document.data()["y"] as? Double
                    self.docID = document.documentID
                    self.constraitingCamera()
                    self.setPoint()
                })
            }
            if self.x == nil {
                self.x = 56.4911
                self.y = 84.9468
                self.constraitingCamera()
                self.setPoint()
            }
        }
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
    
    func deleteOldCoor() {
        if let doc = docID {
            database.collection("users").document(doc).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    self.sendLoc()
                }
            }
        }
        else {
            sendLoc()
        }
    }
    
    func sendLoc() {
        var ref: DocumentReference? = nil
        ref = database.collection("users").addDocument(data: [
            "x": x,
            "y": y,
            "phone": UserDefaults.standard.string(forKey: "phone")
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    
    @IBAction func regionDetail(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        x = locationCoordinate.latitude
        y = locationCoordinate.longitude
        setPoint()
        deleteOldCoor()
    }
    
    func setPoint() {
        mapView.removeAnnotations(mapView.annotations)
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
