//
//  SegmentedTableViewCell.swift
//  imitoSettingsFramework
//
//  Created by Eugene Naloiko on 25.06.2023.
//

import UIKit
import WoundGenius

class SegmentedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelElement: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var valueChanged: ((Int)->())?
    
    var isEnabled: Bool = false {
        didSet {
            self.contentView.backgroundColor = isEnabled ? .clear : WGConstants.Color.lightSemitransparentBackground
            self.segmentedControl.isEnabled = isEnabled
        }
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        valueChanged?(segmentedControl.selectedSegmentIndex)
    }
}
