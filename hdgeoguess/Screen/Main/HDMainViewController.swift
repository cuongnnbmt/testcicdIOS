//
//  HDMainViewController.swift
//  hdgeoguess
//
//  Created by macOS on 27/02/2023.
//

import UIKit
import GameKit

class HDMainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginGameCenter()
    }

    @IBAction func touchPlayFriends(_ sender: Any) {
        //share friend
        if let urlStr = NSURL(string: "https://apps.apple.com/us/app/\(InAppMNG.appID)?ls=1&mt=8") {
            let objectsToShare = [urlStr]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popup = activityVC.popoverPresentationController {
                    popup.sourceView = self.view
                    popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                }
            }

            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func touchSinglePlayer(_ sender: Any) {
        GameMNG.shared.clearAllPlayer()
        GameMNG.shared.addPlayer(player: Player(id: 0, name: "Player 1"))
        let vc = SinglePlayerModeViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func touchUpgrade(_ sender: Any) {
        InAppMNG.goPremium(vc: self)
    }
    
    @IBAction func touchCompetitive(_ sender: Any) {
        GameMNG.shared.clearAllPlayer()
        GameMNG.shared.addPlayer(player: Player(id: 0, name: "Player 1"))
        GameMNG.shared.addPlayer(player: Player(id: 1, name: "Player 2"))
        let vc = SinglePlayerModeViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func touchMultiplayer(_ sender: Any) {
        //achivement
        let vc = GKGameCenterViewController()
        vc.viewState = .leaderboards
        vc.leaderboardIdentifier = GameMNG.shared.LEADERBOARD_ID
        vc.gameCenterDelegate = self
        self.present(vc, animated: true)
    }

    func loginGameCenter() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { (vc, error) in
            if vc != nil {
                self.present(vc!, animated: true)
            } else if GKLocalPlayer.local.isAuthenticated {
                
            }
        }
    }
}

extension HDMainViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        self.dismiss(animated: true)
    }
}
