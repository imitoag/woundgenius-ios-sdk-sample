//
//  Series.swift
//  SampleObjc
//
//  Created by Eugene Naloiko on 13.03.2024.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
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
