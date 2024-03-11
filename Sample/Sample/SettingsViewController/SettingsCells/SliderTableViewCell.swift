//
//  SliderTableViewCell.swift
//  Sample
//
//  Created by Eugene Naloiko on 20.06.2023.
//

import UIKit
import WoundGenius

class SliderTableViewCell: UITableViewCell {

    @IBOutlet weak var labelElement: UILabel!
    @IBOutlet weak var sliderElement: UISlider!
    
    var isEnabled: Bool = false {
        didSet {
            self.contentView.backgroundColor = isEnabled ? .clear : WGConstants.Color.lightSemitransparentBackground
            self.sliderElement.tintColor = WGConstants.Color.red
            self.sliderElement.isEnabled = isEnabled
        }
    }
    
    var valueChanged: ((Int)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        valueChanged?(Int(sliderElement.value))
    }
}
