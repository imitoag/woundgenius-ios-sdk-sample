//
//  SettingsTableViewControllerPresenter.swift
//  Sample
//
//  Created by Eugene Naloiko on 20.06.2023.
//

import UIKit

enum SettingKey: String {
    case licenseKey
    case videoModeEnabled
    case markerModeEnabled
    case photoModeEnabled
    case rulerModeEnabled
    case localStorageMediaEnabled
    case bodyPartPickerOnCapturingEnabled
    case frontalCameraEnabled
    case autoDetectionType
    case maxNumberOfMediaInt
    case multipleOutlinesPerImageEnabled
    case primaryButtonColor
    case lightBackgroundColor
}

struct SettingsSection {
    let labelText: String
    let elements: [SettingsElement]
}

struct SettingsElement {
    let labelText: String
    let key: SettingKey
    let cellId: String
    let minValue: Int?
    let maxValue: Int?
    let options: [String]?
    
    init(labelText: String,
         key: SettingKey,
         cellId: String,
         minValue: Int? = nil,
         maxValue: Int? = nil,
         options: [String]? = nil) {
        self.labelText = labelText
        self.key = key
        self.cellId = cellId
        self.minValue = minValue
        self.maxValue = maxValue
        self.options = options
    }
}

class SettingsTableViewControllerPresenter: NSObject {
    
    let sections: [SettingsSection] = {
        return [
            SettingsSection(labelText: "License Key", elements: [
                SettingsElement(labelText: "License",
                                key: .licenseKey,
                                cellId: String(describing: TextFieldTableViewCell.self))
            ]),
            SettingsSection(labelText: "Modes Configurations",
                            elements: [
                                SettingsElement(labelText: "Video",
                                                key: .videoModeEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self)),
                                SettingsElement(labelText: "Marker Measurement",
                                                key: .markerModeEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self)),
                                SettingsElement(labelText: "Photo",
                                                key: .photoModeEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self)),
                                SettingsElement(labelText: "Ruler",
                                                key: .rulerModeEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self)),
                            ]),
            SettingsSection(labelText: "Max Number of Media",
                            elements: [
                                SettingsElement(labelText: "Max Number of Media",
                                                key: .maxNumberOfMediaInt,
                                                cellId: String(describing: SliderTableViewCell.self),
                                                minValue: 1,
                                                maxValue: 99)
                            ]),
            SettingsSection(labelText: "Other",
                            elements: [
                                SettingsElement(labelText: "Import from Camera Roll",
                                                key: .localStorageMediaEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self)),
                                SettingsElement(labelText: "Body Part Picker while Capturing",
                                                key: .bodyPartPickerOnCapturingEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self)),
                                SettingsElement(labelText: "Frontal Camera Enabled",
                                                key: .frontalCameraEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self)),
                                SettingsElement(labelText: "Autodetect",
                                                key: .autoDetectionType,
                                                cellId: String(describing: SegmentedTableViewCell.self),
                                                options: ["None", "Wound", "Tissue Types"]),
                                SettingsElement(labelText: "Multiple Outlines per Image",
                                                key: .multipleOutlinesPerImageEnabled,
                                                cellId: String(describing: SwitchTableViewCell.self))
                            ]),
            SettingsSection(labelText: "Color", elements: [
                SettingsElement(labelText: "Primary Button",
                                key: .primaryButtonColor,
                                cellId: String(describing: SegmentedTableViewCell.self),
                                options: ["imitoRed", "Blue", "Green"]),
                SettingsElement(labelText: "Light BG",
                                key: .lightBackgroundColor,
                                cellId: String(describing: SegmentedTableViewCell.self),
                                options: ["white", "lightGray", "yellow"])
            ])                
        ]
    }()
}
