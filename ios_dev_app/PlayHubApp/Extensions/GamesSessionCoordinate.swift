//
//  GamesSessionCoordinate.swift
//  ios_dev_app
//
//  Created by student2 on 2026-07-09.
//

import CoreLocation

extension GameSession {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
