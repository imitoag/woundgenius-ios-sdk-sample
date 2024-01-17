//
//  SwitchTableViewCell.swift
//  Sample
//
//  Created by Eugene Naloiko on 20.06.2023.
//

import UIKit
import WoundGenius

class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelElement: UILabel!
    @IBOutlet weak var switchElement: UISwitch!
    
    var isEnabled: Bool = false {
        didSet {
            self.switchElement.isEnabled = isEnabled
            self.contentView.backgroundColor = isEnabled ? .clear : IMIConstants.Color.lightSemitransparentBackground
        }
    }
    
    var valueChanged: ((Bool)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func switchValueChanged(_ sender: Any) {
        valueChanged?(switchElement.isOn)
    }
}
