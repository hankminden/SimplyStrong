//
//  WorkoutTotalTableViewCell.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/24/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

class WorkoutTotalTableViewCell: UITableViewCell {

    @IBOutlet var totalRepCount: UILabel!
    @IBOutlet var totalRepName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
