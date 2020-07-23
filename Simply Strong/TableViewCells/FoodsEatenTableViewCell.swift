//
//  FoodsEatenTableViewCell.swift
//  Simply Strong
//
//  Created by Henry Minden on 7/23/20.
//  Copyright © 2020 ProMeme. All rights reserved.
//

import UIKit

class FoodsEatenTableViewCell: UITableViewCell {

    @IBOutlet var caloriesLabel: UILabel!
    @IBOutlet var foodName: UILabel!
    @IBOutlet var dateEaten: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
