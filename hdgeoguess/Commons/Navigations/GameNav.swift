//
//  GameNav.swift
//  hdgeoguess
//
//  Created by macOS on 05/05/2023.
//

import Foundation
import UIKit

class GameNav: UIView {
    
    var touchOnLeftButton: (() -> ())?
    var touchOnRightButton: (() -> ())?

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var rightImgIcon: UIImageView!
    @IBOutlet weak var leftImgIcon: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var rightButton: UIControl!
    @IBOutlet weak var leftButton: UIControl!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addViewXIB()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addViewXIB()
    }
    
    private func addViewXIB() {
        Bundle.main.loadNibNamed("GameNav", owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundColor = .clear
    }
    
    @IBAction func touchOnRight(_ sender: Any) {
        self.touchOnRightButton?()
    }
    
    @IBAction func touchOnLeft(_ sender: Any) {
        self.touchOnLeftButton?()
    }
    
}
