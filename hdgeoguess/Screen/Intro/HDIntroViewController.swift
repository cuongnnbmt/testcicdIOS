//
//  HDIntroViewController.swift
//  hdgeoguess
//
//  Created by macOS on 20/02/2023.
//

import UIKit

class HDIntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTouchStart(_ sender: Any) {
        let vc = HDMainViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
}
