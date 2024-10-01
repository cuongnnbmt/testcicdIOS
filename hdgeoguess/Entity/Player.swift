//
//  PlayerMode.swift
//  hdgeoguess
//
//  Created by macOS on 05/05/2023.
//

import Foundation

enum Mode {
    case singleInfinity
    case singleClassic
    case singleCountry
    case undefined
}

class PlayMode {
    var displayName: String = ""
    var mode: Mode = .undefined
    var iconName: String = ""
    
    init(displayName: String, iconName: String = "", mode: Mode = .undefined) {
        self.displayName = displayName
        self.iconName = iconName
        self.mode = mode
    }
}

class Player {
    var id: Int = 0
    var name = "Player"
    init(id: Int = 0, name: String = "Player") {
        self.id = id
        self.name = name
    }
}
