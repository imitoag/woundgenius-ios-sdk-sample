//
//  SliderTableViewCell.swift
//  Sample
//
//  Created by Eugene Naloiko on 20.06.2023.
//

import UIKit

class SliderTableViewCell: UITableViewCell {

    @IBOutlet weak var labelElement: UILabel!
    @IBOutlet weak var sliderElement: UISlider!
    
    var valueChanged: ((Int)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        valueChanged?(Int(sliderElement.value))
    }
}
