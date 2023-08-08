//
//  TextFieldTableViewCell.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.07.2023.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelElement: UILabel!
    @IBOutlet weak var textFieldElement: UITextField! {
        didSet {
            textFieldElement.delegate = self
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
