//
//  GameNavViewController.swift
//  hdgeoguess
//
//  Created by macOS on 19/05/2023.
//

import UIKit
import CoreLocation

class GameNavViewController: UIViewController {

    private var cachePlayerList: [Player] = [Player]()
    private var lastVC : UIViewController?
    
    var country: Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        GameMNG.shared.startGame()
        self.cachePlayerList = [Player](GameMNG.shared.playerList())
        GameMNG.shared.currentRound = 1
        self.tempLoccation = GameMNG.shared.generateRandomLocation(country: self.country)
        self.postRequest(lat: self.tempLoccation.latitude, long: self.tempLoccation.longitude) { [weak self] locCoordinate in
            DispatchQueue.main.async {
                self?.tempLoccation = locCoordinate
                self?.processPlayer(idx: 0)
            }
        }
    }

    private var tempLoccation: CLLocationCoordinate2D!
    
    func processPlayer(idx: Int){
        if idx >= cachePlayerList.count {
            if !GameMNG.shared.isLastRound() {
                GameMNG.shared.currentRound = GameMNG.shared.currentRound + 1
                GameMNG.shared.startRound()
                if let vc = lastVC {
                    self.removeChildRoundVC(vc: vc)
                }
                self.cachePlayerList = [Player](GameMNG.shared.playerList())
                self.tempLoccation = GameMNG.shared.generateRandomLocation(country: self.country)
                self.postRequest(lat: self.tempLoccation.latitude, long: self.tempLoccation.longitude) { [weak self] locCoordinate in
                    DispatchQueue.main.async {
                        self?.tempLoccation = locCoordinate
                        self?.processPlayer(idx: 0)
                    }
                }
            } else {
                GameMNG.shared.endGame()
                self.dismiss(animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100), execute: {
                        if var topController = UIApplication.shared.keyWindow?.rootViewController {
                            while let presentedViewController = topController.presentedViewController {
                                topController = presentedViewController
                            }
                            topController.present(ResultViewController(), animated: true)
                        }
                    })
                }
            }
            return
        }
        let player = cachePlayerList[idx]
        self.instanceGame(player: player, location: self.tempLoccation) { [weak self] in
            self?.processPlayer(idx: idx+1)
        }
    }
    
    func instanceGame(player: Player, location: CLLocationCoordinate2D, onCompleted: @escaping () -> ()) {
        let vc = HDGamePlayViewController()
        vc.player = player
        vc.goalCoordinate = location
        vc.modalPresentationStyle = .overFullScreen
        vc.onNextAction = { [weak self, weak vc] in
            onCompleted()
        }
        vc.onHomeAction = { [weak self, weak vc] in
            self?.dismiss(animated: true)
        }
        self.addChildRoundVC(vc: vc)
    }

    func addChildRoundVC(vc: UIViewController?) {
        guard let vc = vc else { return }
        self.lastVC = vc
        vc.view.frame = self.view.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        vc.view.alpha = 0
        UIView.animate(withDuration: 0.25) {
            vc.view.alpha = 1
        }
    }
    
    func removeChildRoundVC(vc: UIViewController?) {
        guard let vc = vc else { return }
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
 
    func postRequest(lat: Double, long: Double, completedBlock: @escaping (CLLocationCoordinate2D) -> ()) {
        
        let url = URL(string: "https://maps.googleapis.com/$rpc/google.internal.maps.mapsjs.v1.MapsJsInternalService/SingleImageSearch")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("AIzaSyBJp742fgyzlv6afbp1gvnz6LQ91IW1YK8", forHTTPHeaderField: "X-Goog-Api-Key")
        request.addValue("grpc-web-javascript/0.1", forHTTPHeaderField: "X-User-Agent")
        request.addValue("application/json+protobuf", forHTTPHeaderField: "Content-Type")
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.3 Safari/605.1.15 DNT: 1", forHTTPHeaderField: "User-Agent")

        let bodyJson = """
        [["apiv3",null,null,null,"US",null,null,null,null,null,[[false]]],[[null,null,\(lat),\(long)],6700000],[null,["vi","VN"],null,null,null,null,null,null,[2],null,[[[2,true,2],[3,true,2],[10,true,2]]]],[[1,2,3,4,8,6]]]
        """
        request.httpBody = bodyJson.data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                return
            }
            guard let responseData = data else {
                return
            }
            
            do {
                var res = ""
                let patt = """
                -?[0-9]{1,3}(?:\\.[0-9]{1,20})?(\\,)-?[0-9]{1,3}(?:\\.[0-9]{1,20})?
                """
                let str = String(data: responseData, encoding: .utf8)
                guard let str = str else { return }
                let regex = try! NSRegularExpression(pattern: patt)
                let range = NSRange(location: 0, length: str.utf16.count)
                let matches = regex.matches(in: str, options: [], range: range)
                for match in matches {
                    if let range = Range(match.range, in: str) {
                        let name = str[range]
                        if name.count > res.count {
                            res = String(name)
                        }
                    }
                }
                let latlong = res.split(separator: ",")
                let resLat = Double(latlong[0])
                let resLong = Double(latlong[1])
                print(str)
                completedBlock(CLLocationCoordinate2D(latitude: resLat ?? lat, longitude: resLong ?? long))
            } catch let error {
                print(error.localizedDescription)
                completedBlock(CLLocationCoordinate2D(latitude: lat, longitude: long))
            }
        }
        task.resume()
    }

}
