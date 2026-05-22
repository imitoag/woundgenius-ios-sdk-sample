//
//  StandaloneAssessmentManager.swift
//  Sample
//
//  Created by apple on 07.05.2026.
//

import UIKit
import WoundGenius

class StandaloneAssessmentManager: NSObject, StandaloneAssessmentManagerProtocol {
    var assessments: [WoundGenius.AssessmentModel] = []
    
    func add(assessment: WoundGenius.AssessmentModel) {
        self.assessments.append(assessment)
    }
}
