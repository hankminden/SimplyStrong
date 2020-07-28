//
//  FoodSuggestionTableViewCell.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/25/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

class FoodSuggestionTableViewCell: UITableViewCell {

    @IBOutlet var foodName: UILabel!
    @IBOutlet var calories: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
