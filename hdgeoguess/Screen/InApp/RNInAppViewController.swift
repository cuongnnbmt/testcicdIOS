//
//  RNInAppViewController.swift
//

import UIKit
import ProgressHUD
import Toast_Swift

class RNInAppViewController: UIViewController {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lbHelp: UILabel!
    
    @IBOutlet weak var btn4: UIButton!
    
    var timer: Timer!
    var distance = 0.0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "RNInAppViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnClose.alpha = 0.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
                self.btnClose.alpha = 1.0
            } completion: { (Bool) in
            }
        }
        self.distance = GameMNG.shared.getLastGameEndTime() + GameMNG.shared.timeWaiting - Date().timeIntervalSince1970

        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            self?.distance = (self?.distance ?? 0) - 1
            if self?.distance ?? 0 < 0 {
                self?.distance = 0
            }
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            formatter.allowedUnits = [.second, .minute]
            let formattedTimeLeft = formatter.string(from: self?.distance ?? 0)
            self?.lbHelp.text = "or waiting \(formattedTimeLeft ?? "-:-") to continue play"
        })
        if GameMNG.shared.canPlayGame() {
            self.lbHelp.isHidden = true
        }
    }

    deinit {
        self.timer.invalidate()
    }
    
    func decorButton(button: UIButton) {
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func touchOnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func touchOnPay(productID: String) {
        InAppMNG.purchaseProduct(productID: productID) { result in
            switch result {
            case .success:
                self.dismiss(animated: true) {
                    let vc = UIApplication.shared.windows.first?.rootViewController
                    vc?.view.makeToast("Success!")
                }
            default: break
            }
        }
    }
        
    @IBAction func touchOnRestorePurchase(_ sender: Any) {
        InAppMNG.restorePurchases { (_) in

        }
    }
        
    @IBAction func buy4(_ sender: Any) {
        touchOnPay(productID: InAppMNG.keyProversion1Month)
    }

    @IBAction func buy5(_ sender: Any) {
        touchOnPay(productID: InAppMNG.keyProversion12Month)
    }

    @IBAction func touchPrivacy(_ sender: Any) {
        UIApplication.shared.open(URL(string: InAppMNG.privacyURL)!)
    }
    
    @IBAction func touchTerms(_ sender: Any) {
        UIApplication.shared.open(URL(string: InAppMNG.termOfUseURL)!)
    }
}
