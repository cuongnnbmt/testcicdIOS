//
//  ResultViewController.swift
//  hdgeoguess
//
//  Created by macOS on 05/05/2023.
//

import UIKit
import MapKit
import GameKit

class ResultViewController: UIViewController {

    @IBOutlet weak var gameNav: GameNav!
    @IBOutlet weak var stView: UIStackView!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    @IBOutlet weak var line1: UIView!
    @IBOutlet weak var lbTotal2: UILabel!
    @IBOutlet weak var tbView2: UITableView!
    @IBOutlet weak var tbView1: UITableView!
    @IBOutlet weak var lbTotal1: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavView()
        self.tbView1.dataSource = self
        self.tbView1.delegate = self
        self.tbView1.register(UINib(nibName: "ScoreTableViewCell", bundle: nil), forCellReuseIdentifier: "ScoreTableViewCell")

        self.tbView2.dataSource = self
        self.tbView2.delegate = self
        self.tbView2.register(UINib(nibName: "ScoreTableViewCell", bundle: nil), forCellReuseIdentifier: "ScoreTableViewCell")
        if GameMNG.shared.playerList().count == 1 {
            self.view2.isHidden = true
            self.line1.isHidden = true
        }
        let df = MKDistanceFormatter()
        df.unitStyle = .full

        if let arr1 = GameMNG.shared.scoreNote[0] {
            let sum1 = arr1.map({$0.score}).reduce(0, +)
            let sum11 = arr1.map({$0.distance}).reduce(0, +)
            let prettyString1 = df.string(fromDistance: sum11)
            self.lbTotal1.text = "TOTAL: \(Int(sum1)) score, \(prettyString1)"
            reportScore(score: Int(sum1))
        }
        if let arr2 = GameMNG.shared.scoreNote[1] {
            let sum2 = arr2.map({$0.score}).reduce(0, +)
            let sum21 = arr2.map({$0.distance}).reduce(0, +)
            let prettyString2 = df.string(fromDistance: sum21)
            self.lbTotal2.text = "TOTAL: \(Int(sum2)) score, \(prettyString2)"
        }
    }

    func setupNavView() {
        self.gameNav.touchOnLeftButton = { [weak self] in
            self?.dismiss(animated: true)
        }
        self.gameNav.lbTitle.text = "RESULTS"
    }
    
    func reportScore(score: Int) {
        let gScore = GKScore.init(leaderboardIdentifier: GameMNG.shared.LEADERBOARD_ID)
        gScore.value = Int64(score)
        gScore.context = 0
        GKScore.report([gScore])
    }
}

extension ResultViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
}

extension ResultViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tbView1 {
            let count = GameMNG.shared.scoreNote[0]?.count ?? 0
            return count + 1
        }
        if tableView == self.tbView2 {
            let count = GameMNG.shared.scoreNote[1]?.count ?? 0
            return count + 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreTableViewCell", for: indexPath) as! ScoreTableViewCell
        if indexPath.row == 0 {
            cell.label1.text = "Round"
            cell.label2.text = "Distance"
            cell.label3.text = "Score"
            return cell
        }

        if tableView == self.tbView1 {
            if let score = GameMNG.shared.scoreNote[0]?[indexPath.row-1] {
                cell.label1.text = String(score.round)
                let df = MKDistanceFormatter()
                df.unitStyle = .full
                let prettyString = df.string(fromDistance: score.distance)
                cell.label2.text = prettyString
                cell.label3.text = String(Int(score.score))
            }
        }
        if tableView == self.tbView2 {
            if let score = GameMNG.shared.scoreNote[1]?[indexPath.row-1] {
                cell.label1.text = String(score.round)
                let df = MKDistanceFormatter()
                df.unitStyle = .full
                let prettyString = df.string(fromDistance: score.distance)
                cell.label2.text = prettyString
                cell.label3.text = String(Int(score.score))
            }
        }
        return cell
    }
}
