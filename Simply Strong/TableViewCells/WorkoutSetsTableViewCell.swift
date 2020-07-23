//
//  WorkoutSetsTableViewCell.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/18/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

class WorkoutSetsTableViewCell: UITableViewCell {

    @IBOutlet var repsCount: UILabel!
    @IBOutlet var repName: UILabel!
    @IBOutlet var timeDisplay: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
