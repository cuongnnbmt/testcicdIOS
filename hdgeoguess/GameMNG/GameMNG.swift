//
//  GameMNG.swift
//  hdgeoguess
//
//  Created by macOS on 05/05/2023.
//

import Foundation
import CoreLocation
import GameKit

enum RoundState {
    case watchAround
    case selectLocation
    case result
    case undefined
}

class Score {
    var round: Int = 0
    var score: Double = 0
    var distance: Double = 0
    var goalLocation: CLLocationCoordinate2D
    var selectLocation: CLLocationCoordinate2D
    init(round: Int, score: Double, goalLocation: CLLocationCoordinate2D, selectLocation: CLLocationCoordinate2D) {
        self.round = round
        self.score = score
        self.selectLocation = selectLocation
        self.goalLocation = goalLocation
        self.distance = GameMNG.shared.distanceFrom(selectLocation, to: goalLocation)
    }
}

class GameMNG {
    static let shared = GameMNG()
    let LEADERBOARD_ID = "GeoguessLeaderboard"
    var maxScore = 100.0
    var mode: Mode = .undefined
    var maxRoundNum: Int = 0
    var currentRound: Int = 0
    var roundState: RoundState = .undefined
    let timeWaiting = 20 * 60.0 //in seconds
    
    private var players: [Player] = [Player]()
    public var scoreNote: [Int: [Score]] = [Int: [Score]]()
    
    func startGame() {
        self.scoreNote.removeAll()
        self.currentRound = 1
        switch mode {
        case .singleInfinity:
            maxRoundNum = Int.max
        case .singleClassic:
            maxRoundNum = 3
        case .singleCountry:
            maxRoundNum = 3
        case .undefined:
            maxRoundNum = 0
        }
        roundState = .undefined
    }
    
    func startRound() {
        roundState = .undefined
    }
    
    func endRound(player: Player, score: Score) {
        roundState = .undefined
        var scoreList = self.scoreNote[player.id]
        if scoreList == nil {
            scoreList = [Score]()
        }
        scoreList?.append(score)
        self.scoreNote[player.id] = scoreList
    }
        
    func endGame() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "kLastGameEndTime")
    }
    
    func isLastRound() -> Bool {
        return currentRound == maxRoundNum
    }
    
    func getLastGameEndTime() -> TimeInterval {
        return UserDefaults.standard.double(forKey: "kLastGameEndTime")
    }
    
    func canPlayGame() -> Bool {
        if InAppMNG.isProVersion() {
            return true
        }
        return Date().timeIntervalSince1970 - getLastGameEndTime() >= self.timeWaiting
    }
    
    func generateRandomLocation(country: Country?) -> CLLocationCoordinate2D {
        var countryNotNil: Country!
        if country == nil {
            let countries = GameMNG.shared.parseCountry()
            countryNotNil = countries.randomElement()
        } else {
            countryNotNil = country!
        }
        var lat = countryNotNil.bounds.min.lat
        var long = countryNotNil.bounds.min.lng
        lat = Double.random(in: 0.0 ..< 0.99)*(countryNotNil.bounds.max.lat-lat)+lat
        long = Double.random(in: 0.0 ..< 0.99)*(countryNotNil.bounds.max.lng-long)+long
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func playerList() -> [Player] {
        return self.players
    }

    func clearAllPlayer() {
        self.players.removeAll()
    }
    
    func addPlayer(player: Player) {
        self.players.append(player)
    }
    
    func removePlayer(player: Player) {
        guard let idx = self.players.firstIndex(where: {$0.id == player.id}) else {return}
        self.players.remove(at: idx)
    }
    
    func calcScore(selectedLoc: CLLocationCoordinate2D, goalLoc: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation.init(latitude: selectedLoc.latitude, longitude: selectedLoc.longitude)
        let location2 = CLLocation.init(latitude: goalLoc.latitude, longitude: goalLoc.longitude)
        let distance = self.distanceFrom(selectedLoc, to: goalLoc) //meters
        let earthRoundInMeters = 40075000.0 //meters
        let score = (((earthRoundInMeters - distance) / earthRoundInMeters) * maxScore)
        return score > 0 ? score : 0
    }
    
    func distanceFrom(_ loc1: CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> Double{
        let location1 = CLLocation.init(latitude: loc1.latitude, longitude: loc1.longitude)
        let location2 = CLLocation.init(latitude: to.latitude, longitude: to.longitude)
        return location1.distance(from: location2) //meters
    }
    
    private var countries: [Country] = [Country]()
    func parseCountry() -> [Country] {
        if countries.isEmpty {
            if let path = Bundle.main.path(forResource: "country", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    let decoder = JSONDecoder()
                    let countries = try! decoder.decode([Country].self, from: data)
                    self.countries = countries
                    return countries
                } catch {
                    return [Country]()
                }
            }
            return [Country]()
        } else {
            return countries
        }
    }

}
