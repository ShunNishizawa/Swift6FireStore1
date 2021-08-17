//
//  CustomCell.swift
//  Swift6FireStore1
//
//  Created by 西澤駿 on 2021/05/23.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
