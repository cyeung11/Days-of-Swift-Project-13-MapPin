//
//  DidSelectLocationCallback.swift
//  Project-13 Map Pin
//
//  Created by Chris on 6/10/2018.
//  Copyright © 2018 Chris. All rights reserved.
//

import Foundation
import MapKit

protocol DidSelectLocationCallback {
    func didSelect(locationAt location: CLLocationCoordinate2D, withAdditionalInfo info: [CLPlacemark]?)
}
