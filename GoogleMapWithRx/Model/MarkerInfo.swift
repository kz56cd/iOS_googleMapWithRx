
//
//  MarkerInfo.swift
//  GoogleMapWithRx
//
//  Created by Masakazu Sano on 2018/06/08.
//  Copyright © 2018年 Masakazu Sano. All rights reserved.
//

import Foundation
import GoogleMaps

struct MarkerInfo {
    let marker: GMSMarker
    let space: Space
    
    init(space: Space) {
        self.space = space
        
        marker = GMSMarker(
            position: CLLocationCoordinate2D(
                latitude: space.latitude,
                longitude: space.longitude
            )
        )
        marker.title = "¥ \(space.minPrice)(id: \(space.id))"
        marker.tracksInfoWindowChanges = true
        
        marker
        
        marker.isDraggable = true
        marker.icon = #imageLiteral(resourceName: "pin")
    }
}
