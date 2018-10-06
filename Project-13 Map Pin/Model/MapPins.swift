//
//  MapPins.swift
//  Project-13 Map Pin
//
//  Created by Chris on 2/10/2018.
//  Copyright © 2018 Chris. All rights reserved.
//

import Foundation
import MapKit

private let bristol = Pin(coordinate: CLLocationCoordinate2D(latitude: 51.454514, longitude: -2.587910), title: "Bristol", subtitle: "Dream Place to Live")
private let paris = Pin(coordinate: CLLocationCoordinate2D(latitude: 48.856613, longitude: 2.352222), title: "Paris", subtitle: "City of Humanity")
private let hongKong = Pin(coordinate: CLLocationCoordinate2D(latitude: 22.298605, longitude: 114.174479), title: "Hong Kong", subtitle: "Home Town")

struct MapPins: Encodable {
    
    var pins: [Pin]
    
    init() {
        if let readPin = FileHelper.default.read(fileName: "map_pins", as: [Pin].self, fromCache: false){
            pins = readPin
        } else {
            pins = [Pin]()
            pins.append(bristol)
            pins.append(paris)
            pins.append(hongKong)
        }
    }
    
    func save() {
        FileHelper.default.save(file: self.pins, withName: "map_pins", asCache: false)
    }

}
