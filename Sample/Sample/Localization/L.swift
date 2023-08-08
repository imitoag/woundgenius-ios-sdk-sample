//
//  L.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.12.2022.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit

class L: NSObject {
    static func str(_ key: String) -> String
    {
        return NSLocalizedString(key, comment: "")
    }
}
