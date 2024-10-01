//
//  SinglePlayerModeViewController.swift
//  hdgeoguess
//
//  Created by macOS on 05/05/2023.
//

import UIKit

class SinglePlayerModeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gameNav: GameNav!
    
    var modes: [PlayMode] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavView()
        modes = [PlayMode(displayName: "Classic Mode", iconName: "card-daily-challenge-square.ec399805", mode: .singleClassic),
                 PlayMode(displayName: "Country Streaks", iconName: "card-quickplay.53d9ed7e", mode: .singleCountry),
                 PlayMode(displayName: "Infinity", iconName: "card-maprunner-square.5766f379", mode: .singleInfinity)]
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "SinglePlayerModeCollectionViewCell", bundle: nibBundle), forCellWithReuseIdentifier: "SinglePlayerModeCollectionViewCell")
    }

    func setupNavView() {
        self.gameNav.touchOnLeftButton = { [weak self] in
            self?.dismiss(animated: true)
        }
        self.gameNav.lbTitle.text = "SINGLE PLAYER MODES"
    }
}

extension SinglePlayerModeViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = collectionView.bounds.size.height
        let w = h * 11.0 / 9.0
        return CGSize(width: w, height: h)
    }
}

extension SinglePlayerModeViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        modes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SinglePlayerModeCollectionViewCell", for: indexPath) as! SinglePlayerModeCollectionViewCell
        let mode = modes[indexPath.row]
        cell.lbTitle.text = mode.displayName
        cell.ivImage.image = UIImage(named: mode.iconName)
        return cell
    }
}

extension SinglePlayerModeViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mode = modes[indexPath.row]
        GameMNG.shared.mode = mode.mode
        if GameMNG.shared.canPlayGame() {
            if mode.mode == .singleClassic {
                let vc = GameNavViewController()
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false)
            }
            if mode.mode == .singleInfinity {
                let vc = GameNavViewController()
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false)
            }
        } else {
            InAppMNG.goPremium(vc: self)
        }
        if mode.mode == .singleCountry {
            let vc = CountrySelectViewController()
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }

    }
}
