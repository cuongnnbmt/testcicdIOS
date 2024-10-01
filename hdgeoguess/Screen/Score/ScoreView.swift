//
//  ScoreView.swift
//  hdgeoguess
//
//  Created by macOS on 19/05/2023.
//

import UIKit
import MKRingProgressView
import UICountingLabel


class ScoreView: UIView {
    
    var onNextAction: (() -> ())?
    var onHomeAction: (() -> ())?

    @IBOutlet weak var view: UIView!

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lbTitleScore: UILabel!
    @IBOutlet weak var lbScore: UICountingLabel!
    @IBOutlet weak var ringProgressView: RingProgressView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var resultView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        nibSetup()
    }

    @IBAction func touchOnNext(_ sender: Any) {
        self.onNextAction?()
        self.onNextAction = nil
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
    }

    @IBAction func touchOnHome(_ sender: Any) {
        self.onHomeAction?()
        self.onHomeAction = nil
    }
    
    private func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "ScoreView", bundle: nil)
        let nibView = nib.instantiate(withOwner: self).first as! UIView
        return nibView
    }

}
