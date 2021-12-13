//
//  Staff.swift
//  HealthyFood
//
//  Created by Sergio Ramos on 28.06.2021.
//

import MapKit

class Staff: NSObject, MKAnnotation {
    
    let title: String?
    let coor: String?
    let coordinate: CLLocationCoordinate2D
    
    init(
        title: String?,
        coor: String?,
        coordinate: CLLocationCoordinate2D
      ) {
        self.title = title
        self.coor = coor
        self.coordinate = coordinate
        super.init()
    }
    
    var subtitle: String? {
        return coor
    }
}
