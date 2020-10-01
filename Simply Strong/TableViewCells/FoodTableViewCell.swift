//
//  FoodTableViewCell.swift
//  Simply Strong
//
//  Created by Henry Minden on 10/1/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {

    @IBOutlet var foodName: UILabel!
    @IBOutlet var calories: UILabel!
    @IBOutlet var created: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
