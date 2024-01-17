//
//  DescriptionTableViewCell.swift
//  Sample
//
//  Created by apple on 23.12.2023.
//

import UIKit
import WoundGenius

class DescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var isEnabled: Bool = false {
        didSet {
            self.contentView.backgroundColor = isEnabled ? .clear : IMIConstants.Color.lightSemitransparentBackground
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
