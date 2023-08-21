//
//  SettingsTableViewController.swift
//  Sample
//
//  Created by Eugene Naloiko on 20.06.2023.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    private let presenter = SettingsTableViewControllerPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sections[section].labelText
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sections[section].elements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = presenter.sections[indexPath.section].elements[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: element.cellId, for: indexPath)
        
        switch element.cellId {
        case String(describing: SwitchTableViewCell.self):
            let switchCell = cell as! SwitchTableViewCell
            switchCell.labelElement.text = element.labelText
            switchCell.switchElement.isOn = UserDefaults.standard.bool(forKey: element.key.rawValue)
            
            switchCell.valueChanged = { newValue in
                UserDefaults.standard.set(newValue, forKey: element.key.rawValue)
                UserDefaults.standard.synchronize()
            }
            return switchCell
        case String(describing: SliderTableViewCell.self):
            let sliderCell = cell as! SliderTableViewCell
            sliderCell.labelElement.text = "\(element.labelText): \(UserDefaults.standard.integer(forKey: element.key.rawValue))"
            sliderCell.sliderElement.value = Float(UserDefaults.standard.integer(forKey: element.key.rawValue))
            sliderCell.sliderElement.minimumValue = Float(element.minValue ?? 0)
            sliderCell.sliderElement.maximumValue = Float(element.maxValue ?? 100)
            sliderCell.valueChanged = { [weak sliderCell] newValue in
                sliderCell?.labelElement.text = "\(element.labelText): \(UserDefaults.standard.integer(forKey: element.key.rawValue))"
                UserDefaults.standard.set(newValue, forKey: element.key.rawValue)
                UserDefaults.standard.synchronize()
            }
            return sliderCell
        case String(describing: TextFieldTableViewCell.self):
            let textFieldCell = cell as! TextFieldTableViewCell
            textFieldCell.labelElement.text = element.labelText
            textFieldCell.textFieldElement.text = UserDefaults.standard.string(forKey: element.key.rawValue)
            textFieldCell.valueChanged = { newValue in
                UserDefaults.standard.set(newValue, forKey: element.key.rawValue)
                UserDefaults.standard.synchronize()
            }
        case String(describing: SegmentedTableViewCell.self):
            let segmentedCell = cell as! SegmentedTableViewCell
            segmentedCell.labelElement.text = element.labelText
            if let options = element.options {
                for (index, option) in options.enumerated() {
                    segmentedCell.segmentedControl.setTitle(option, forSegmentAt: index)
                }
            }
            segmentedCell.segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: element.key.rawValue)
            segmentedCell.valueChanged = { newValue in
                UserDefaults.standard.set(newValue, forKey: element.key.rawValue)
                UserDefaults.standard.synchronize()
            }
        default:
            assertionFailure()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
