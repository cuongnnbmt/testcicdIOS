//
//  Bounds.swift
//  hdgeoguess
//
//  Created by macOS on 17/05/2023.
//

import Foundation
import CoreLocation

struct LatLng: Codable {
    var lat: CLLocationDegrees
    var lng: CLLocationDegrees
}

struct Img: Codable {
    var backgroundLarge: String
    var incomplete: Bool
}

struct Bounds: Codable {
    var min: LatLng
    var max: LatLng
}

struct Country: Codable {
    var id: String = ""
    var name: String = ""
    var description: String = ""
    var images: Img
    var bounds: Bounds

    func getImgURL() -> URL {
        let str = "https://www.geoguessr.com/images/auto/2048/1536/ce/0/plain/" + images.backgroundLarge
        return URL(string: str)!
    }
}
