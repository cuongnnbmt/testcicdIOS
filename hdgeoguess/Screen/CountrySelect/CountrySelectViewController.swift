//
//  CountrySelectViewController.swift
//  hdgeoguess
//
//  Created by macOS on 05/05/2023.
//

import UIKit
import Kingfisher

class CountrySelectViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gameNav: GameNav!
    
    var countries: [Country] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavView()
        countries = GameMNG.shared.parseCountry()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "CountrySelectCollectionViewCell", bundle: nibBundle), forCellWithReuseIdentifier: "CountrySelectCollectionViewCell")
    }
    
    func setupNavView() {
        self.gameNav.touchOnLeftButton = { [weak self] in
            self?.dismiss(animated: true)
        }
        self.gameNav.lbTitle.text = "COUNTRY SELECTED"
    }
}

extension CountrySelectViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let column = 4.0
        let spacing = 16.0
        let w = (collectionView.bounds.size.width - ((column - 1) * spacing)) / column
        let h = w * 11.0 / 9.0
        return CGSize(width: w, height: h)
    }
}

extension CountrySelectViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountrySelectCollectionViewCell", for: indexPath) as! CountrySelectCollectionViewCell
        let country = countries[indexPath.row]
        cell.lbTitle.text = country.name
        cell.ivImage.kf.setImage(with: country.getImgURL())
        return cell
    }
}

extension CountrySelectViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if GameMNG.shared.canPlayGame() {
            let country = countries[indexPath.row]
            let vc = GameNavViewController()
            vc.country = country
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        } else {
            InAppMNG.goPremium(vc: self)
        }
    }
}
