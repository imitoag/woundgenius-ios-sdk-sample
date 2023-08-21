//
//  SegmentedTableViewCell.swift
//  imitoSettingsFramework
//
//  Created by Eugene Naloiko on 25.06.2023.
//

import UIKit

class SegmentedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelElement: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var valueChanged: ((Int)->())?
    
    @IBAction func valueChanged(_ sender: Any) {
        valueChanged?(segmentedControl.selectedSegmentIndex)
    }
}
