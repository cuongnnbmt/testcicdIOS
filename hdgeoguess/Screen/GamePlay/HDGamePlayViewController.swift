//
//  HDGamePlayViewController.swift
//  hdgeoguess
//
//  Created by macOS on 22/02/2023.
//

import UIKit
import WebKit
import GoogleMaps
import MapKit
import MKRingProgressView
import UICountingLabel


class HDGamePlayViewController: UIViewController {
    
    var onNextAction: (() -> ())?
    var onHomeAction: (() -> ())?
    
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    @IBOutlet weak var scoreView: ScoreView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var webkit: FullScreenWKWebView!
    @IBOutlet weak var roundLabel: UILabel!
    
    @IBOutlet weak var mapOverlayView: UIControl!
    @IBOutlet weak var mapViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var resultView: UIView!
    
    private var gmapView: GMSMapView?
    private var tapMakers: GMSMarker?
    private var tapCoordinate: CLLocationCoordinate2D?
    
    var player: Player!
    var currentRound: Int = 0
    var goalCoordinate: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webkit.navigationDelegate = self
        
        GameMNG.shared.roundState = .watchAround
        
        self.scoreView.onNextAction = { [weak self] in
            self?.onNextAction?()
        }
        self.scoreView.onHomeAction = { [weak self] in
            self?.onHomeAction?()
        }
        
        hintLabel.text = "Press the map button to place your guess"
        roundLabel.text = "\(player.name), Round \(GameMNG.shared.currentRound): "
        
        DispatchQueue.main.async {
            let url = URL(string: "https://www.instantstreetview.com/@\(self.goalCoordinate.latitude),\(self.goalCoordinate.longitude),12h,0p,0z")
            self.webkit.load(URLRequest(url: url!))
            print("origin (\(self.goalCoordinate.latitude),\(self.goalCoordinate.longitude)) " + "url : " + url!.absoluteString)
        }
    }
    
    @IBAction func touchMapOvelay(_ sender: Any) {
        hideMap()
        GameMNG.shared.roundState = .watchAround
    }
    
    @IBAction func touchBtnMap(_ sender: Any) {
        showMap()
        GameMNG.shared.roundState = .selectLocation
    }
    
    @IBAction func touchBtnSubmit(_ sender: Any) {
        guard let cordinate = self.tapCoordinate else { return }
        self.btnSubmit.isHidden = true
        self.addLine(start: cordinate, end: self.goalCoordinate)
        GameMNG.shared.roundState = .result
        hintLabel.text = "ROUND \(GameMNG.shared.currentRound) RESULT"
        roundLabel.text = "\(player.name): "
        let score = GameMNG.shared.calcScore(selectedLoc: cordinate, goalLoc: self.goalCoordinate)
        
        self.resultView.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.resultView.alpha = 1
        } completion: { res in
            let ringProgressView = RingProgressView(frame: CGRect(x: 0, y: 0, width: self.scoreView.ringProgressView.bounds.size.width, height: self.scoreView.ringProgressView.bounds.size.height))
            ringProgressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            ringProgressView.startColor = .red
            ringProgressView.endColor = .magenta
            ringProgressView.ringWidth = 25
            ringProgressView.progress = 0.0
            self.scoreView.ringProgressView.addSubview(ringProgressView)
            UIView.animate(withDuration: 0.5) {
                ringProgressView.progress = score/GameMNG.shared.maxScore
            }
            self.scoreView.lbScore.format = "%d"
            self.scoreView.lbScore.count(from: 0, to: CGFloat(Int(score)), withDuration: 0.5)
        }
        
        GameMNG.shared.endRound(player: self.player, score: Score(round: GameMNG.shared.currentRound, score: Double(Int(score)), goalLocation: cordinate, selectLocation: self.goalCoordinate))
    }
    
    private func hideMap() {
        hintLabel.text = "Press the map button to place your guess"
        roundLabel.text = "\(player.name), Round \(GameMNG.shared.currentRound): "
        
        mapViewWidth.constant = 0
        self.mapOverlayView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.view.layoutIfNeeded()
        } completion: { res in
            self.mapOverlayView.isHidden = true
            self.mapView.subviews.forEach({ $0.removeFromSuperview() })
        }
    }
    
    private func showMap() {
        let camera = GMSCameraPosition(latitude: 49.040558, longitude: -48.180331, zoom: 2)
        
        self.gmapView = GMSMapView.map(withFrame: self.mapView.bounds, camera: camera)
        self.gmapView?.delegate = self
        self.gmapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.addSubview(gmapView!)
        
        mapViewWidth.constant = UIScreen.main.bounds.size.width
        self.mapOverlayView.isHidden = false
        self.mapOverlayView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.mapOverlayView.alpha = 1
            self.btnSubmit.isHidden = false
            self.view.layoutIfNeeded()
        } completion: { res in
        }
        
        hintLabel.text = "Tap the map to guess the location"
        roundLabel.text = "\(player.name), Round \(GameMNG.shared.currentRound): "
        
    }
    
    private func newImage(text: String) -> UIImage? {
        let padding = 26.0
        let lb = UILabel.init()
        lb.font = .boldSystemFont(ofSize: 12)
        lb.text = text
        let s = lb.sizeThatFits(CGSize(width: 10000, height: 30))
        let size = CGSize(width: s.width, height: s.height + padding)
        let data = text.data(using: .utf8, allowLossyConversion: true)
        let drawText = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Bold", size: 12)!,
            NSAttributedString.Key.foregroundColor: UIColor.red,
        ]
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        drawText?.draw(in: CGRectMake(0, 0, s.width, s.height), withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private func addLine(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        self.tapMakers?.map = nil
        
        // Creates a start marker of the map.
        let markerS = GMSMarker()
        markerS.position = start
        markerS.icon = UIImage(named: "ic_triangle_red")
        markerS.title = "Start"
        markerS.snippet = "Australia"
        markerS.map = gmapView
        
        // Creates a end marker of the map.
        let markerE = GMSMarker()
        //markerE.icon = UIImage(named: "ic_map_guess")
        markerE.position =  end
        markerE.title = "End"
        markerE.snippet = "Australia"
        markerE.map = gmapView
        
        // Creates a label distance marker of the map.
        let loc1 = CLLocation.init(latitude: start.latitude, longitude: start.longitude)
        let loc2 = CLLocation.init(latitude: end.latitude, longitude: end.longitude)
        
        let markerD = GMSMarker()
        let distance = loc1.distance(from: loc2)
        let df = MKDistanceFormatter()
        df.unitStyle = .full
        let prettyString = df.string(fromDistance: distance)
        
        markerD.icon = self.newImage(text: prettyString)
        markerD.position = CLLocationCoordinate2D(latitude: start.latitude, longitude: start.longitude)
        markerD.title = nil
        markerD.snippet = nil
        markerD.map = gmapView
        
        let path = GMSMutablePath()
        path.add(start)
        path.add(end)
        
        let polyline = GMSPolyline(path: path)
        polyline.map = gmapView
        polyline.strokeWidth = 3
        polyline.strokeColor = .red
        
        // Animate camera to center the line
        gmapView?.animate(with: GMSCameraUpdate.fit(GMSCoordinateBounds(path: path), withPadding: 100))
    }
        
}

class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension HDGamePlayViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if (GameMNG.shared.roundState != .selectLocation) {
            return
        }
        if (self.tapMakers != nil) {
            self.tapMakers?.map = nil
        }
        self.tapMakers = GMSMarker()
        self.tapMakers?.icon = UIImage(named: "ic_triangle_red")
        self.tapMakers?.position = coordinate
        self.tapMakers?.title = nil
        self.tapMakers?.snippet = nil
        self.tapMakers?.map = self.gmapView
        self.tapCoordinate = coordinate
        print(coordinate.latitude.description + "///" + coordinate.longitude.description)
    }
}

extension HDGamePlayViewController: WKNavigationDelegate {
    
    func jscriptStr() -> String {
        let str = """
        let intervalID;
        hideThem();
        function repeatEverySecond() {
          intervalID = setInterval(hideThem, 1000);
        }
        
        function hideThem() {
            document.getElementById("menu").style.display = "none";
            document.getElementById("address").style.display = "none";
            document.getElementById("disclaimer").style.display = "none";
            document.getElementById("bottom-box").style.display = "none";
            document.getElementById("map-box").style.display = "none";
            document.getElementById("search-box").style.display = "none";
            document.getElementById("top-box").style.display = "none";
        }
        """
        return str
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
            self.webkit.evaluateJavaScript(self.jscriptStr()) { res, err in
            }
        })
        return .allow
    }
    func webView(_ webView: WKWebView, shouldAllowDeprecatedTLSFor challenge: URLAuthenticationChallenge) async -> Bool {
        true
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        .allow
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
            self.webkit.evaluateJavaScript(self.jscriptStr()) { res, err in
            }
        })
        self.loadingActivity.alpha = 0
        self.loadingActivity.isHidden = false
        self.loadingActivity.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadingActivity.isHidden = true
        self.loadingActivity.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
            self.webkit.evaluateJavaScript(self.jscriptStr()) { res, err in
            }
        })
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    }
}
