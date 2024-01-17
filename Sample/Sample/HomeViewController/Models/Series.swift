//
//  Series.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.01.2023.
//

import UIKit

class Series: NSObject {
    /** Date of Creation */
    var timestamp = Date().timeIntervalSince1970
    
    /** Store the results of capturing */
    var captureResults: [Any]
        
    init(captureResults: [Any]) {
        self.captureResults = captureResults
        super.init()
    }
}
