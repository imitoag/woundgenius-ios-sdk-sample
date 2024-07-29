//
//  CaptureResultTableViewCell.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.12.2022.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit

class CaptureResultTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .imiCellBackground()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
