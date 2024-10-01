//
//  ScoreTableViewCell.swift
//  hdgeoguess
//
//  Created by macOS on 12/06/2023.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
