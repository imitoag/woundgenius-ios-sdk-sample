//
//  TextFieldTableViewCell.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.07.2023.
//

import UIKit
import WoundGenius

class TextFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelElement: UILabel!
    @IBOutlet weak var textFieldElement: UITextField! {
        didSet {
            textFieldElement.delegate = self
            textFieldElement.clearButtonMode = .always
        }
    }
    
    var isEnabled: Bool = false {
        didSet {
            self.contentView.backgroundColor = isEnabled ? .clear : IMIConstants.Color.lightSemitransparentBackground
            self.textFieldElement.isEnabled = isEnabled
        }
    }
    
    var valueChanged: ((String?)->())?

    @IBAction func textFieldUpdated(_ sender: Any) {
        valueChanged?(textFieldElement.text)
    }
}

extension TextFieldTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
