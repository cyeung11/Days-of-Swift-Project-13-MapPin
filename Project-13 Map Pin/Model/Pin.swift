//
//  Pin.swift
//  Project-13 Map Pin
//
//  Created by Chris on 2/10/2018.
//  Copyright © 2018 Chris. All rights reserved.
//

import Foundation
import MapKit

class Pin: NSObject, MKAnnotation, Codable {
    var coordinate: CLLocationCoordinate2D{
        set{
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        get{
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude: Double
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}
