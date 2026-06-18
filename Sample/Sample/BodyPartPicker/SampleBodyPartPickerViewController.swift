//
//  BodyPartPickerViewController.swift
//  Sample
//
//  Created by apple on 02.04.2026.
//

import UIKit
import WoundGenius

class SampleBodyPartPickerViewController: UIViewController {
    /** Core Module: A button to show Body Part Picker */
    private let showBodyPartPicker = UIButton(frame: .zero)
    
    /** Universal Body Part Picker Results */
    private var pickedUBodyParts: [UBPPSection]? {
        didSet {
            guard let pickedUBodyParts = pickedUBodyParts, !pickedUBodyParts.isEmpty else {
                self.bodyPartsFrontBackTextView?.removeFromSuperview()
                self.bodyPartsFrontBackTextView = nil
                self.bodyPartsFrontBackView?.removeFromSuperview()
                self.bodyPartsFrontBackView = nil
                self.snapshotFromPresentedFrontBackView?.removeFromSuperview()
                self.snapshotFromPresentedFrontBackView = nil
                self.snapshotFromHiddenFrontBackView?.removeFromSuperview()
                self.snapshotFromHiddenFrontBackView = nil
                return
            }
            
            self.presentBodyPartViews(bodyParts: pickedUBodyParts)
        }
    }
    
    private let woundGeniusPresenter: MyWoundGeniusPresenter
    
    private var bodyPartsFrontBackTextView: WGBodyPartPickerFrontBackTextView?
    private var bodyPartsFrontBackView: WGBodyPartPickerFrontBackView?
    private var snapshotFromPresentedFrontBackView: UIImageView?
    private var snapshotFromHiddenFrontBackView: UIImageView?
    
    private var backgroundColor: UIColor {
        UITraitCollection.current.userInterfaceStyle == .dark ? .secondarySystemGroupedBackground : .white
    }
    
    init(woundGeniusPresenter: MyWoundGeniusPresenter) {
        self.woundGeniusPresenter = woundGeniusPresenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Body Part Picker"
        
        self.setupSubviews()
    }
    
    private func setupSubviews() {
        self.view.backgroundColor = self.backgroundColor
        
        showBodyPartPicker.translatesAutoresizingMaskIntoConstraints = false
        showBodyPartPicker.addTarget(self, action: #selector(startBodyPartPicker), for: .touchUpInside)
        showBodyPartPicker.backgroundColor = UINavigationBar.appearance().tintColor
        showBodyPartPicker.setTitle("Show Body Part Picker", for: .normal)
        showBodyPartPicker.tintColor = UINavigationBar.appearance().tintColor
        showBodyPartPicker.layer.cornerRadius = 5
        showBodyPartPicker.layer.masksToBounds = true
        self.view.addSubview(showBodyPartPicker)
                
        NSLayoutConstraint.activate([
            showBodyPartPicker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            showBodyPartPicker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            showBodyPartPicker.heightAnchor.constraint(equalToConstant: 40),
            showBodyPartPicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    /* WoundGenius: To use only body part picker feature. */
    @objc func startBodyPartPicker() {
        guard let licenseKey = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue), !licenseKey.isEmpty else {
            UIUtils.showOKAlert("No License Key", message: "Please configure the license key in Settings, or contact imito AG support to get it.")
            return
        }
        
        let bpPickerVC = UBPPickerViewController(preselect: self.pickedUBodyParts?
            .flatMap({ $0.items })
            .map({ $0.itemId }),
                                                 languageISO2Alpha: L.str("LANGUAGE_CODE"),
                                                 gender: .female,
                                                 primaryColor: self.woundGeniusPresenter.primaryButtonColor,
                                                 localization: self.woundGeniusPresenter,
                                                 devLogs: { log in
            print(log)
        }) { [weak self] result in
            self?.pickedUBodyParts = result
        }
        self.present(bpPickerVC, animated: true)
    }
}

extension SampleBodyPartPickerViewController {
    
    private func presentBodyPartViews(bodyParts: [UBPPSection]) {
        // Show Front/Back View + Scrollable Text.
        if self.bodyPartsFrontBackTextView == nil {
            let bodyPartsFrontBackTextView = WGBodyPartPickerFrontBackTextView(preselect: bodyParts, language: L.str("LANGUAGE_CODE"), gender: .female, backgroundColor: self.backgroundColor, bodyMapColor: nil, primaryColor: self.woundGeniusPresenter.primaryButtonColor, localization: self.woundGeniusPresenter)
            bodyPartsFrontBackTextView.layer.cornerRadius = 8
            bodyPartsFrontBackTextView.layer.borderColor = UIColor.black.cgColor
            bodyPartsFrontBackTextView.layer.borderWidth = 1
            self.view.addSubview(bodyPartsFrontBackTextView)
            bodyPartsFrontBackTextView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bodyPartsFrontBackTextView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 8),
                bodyPartsFrontBackTextView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
                bodyPartsFrontBackTextView.heightAnchor.constraint(equalToConstant: WGBodyPartPickerFrontBackTextView.recommendedHeight),
                bodyPartsFrontBackTextView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -8)
            ])
            self.bodyPartsFrontBackTextView = bodyPartsFrontBackTextView
        } else {
            self.bodyPartsFrontBackTextView?.updateSelection(bodyParts)
        }
        
        // Show only the Front/Back View.
        guard let bodyPartsFrontBackTextView = bodyPartsFrontBackTextView else { return }
        if self.bodyPartsFrontBackView == nil {
            let bodyPartsFrontBackView = WGBodyPartPickerFrontBackView(preselect: bodyParts.keys, language: L.str("LANGUAGE_CODE"), gender: .female, backgroundColor: self.backgroundColor, bodyMapColor: nil, primaryColor: self.woundGeniusPresenter.primaryButtonColor, localization: self.woundGeniusPresenter)
            bodyPartsFrontBackView.layer.cornerRadius = 8
            bodyPartsFrontBackView.layer.borderColor = UIColor.black.cgColor
            bodyPartsFrontBackView.layer.borderWidth = 1
            self.view.addSubview(bodyPartsFrontBackView)
            bodyPartsFrontBackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bodyPartsFrontBackView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 8),
                bodyPartsFrontBackView.topAnchor.constraint(equalTo: bodyPartsFrontBackTextView.bottomAnchor, constant: 8),
                bodyPartsFrontBackView.heightAnchor.constraint(equalToConstant: WGBodyPartPickerFrontBackTextView.recommendedHeight),
                bodyPartsFrontBackView.widthAnchor.constraint(equalTo: bodyPartsFrontBackView.heightAnchor, multiplier: 1)
            ])
            self.bodyPartsFrontBackView = bodyPartsFrontBackView
        } else {
            self.bodyPartsFrontBackView?.updateSelection(bodyParts.keys)
        }
        
        guard let bodyPartsFrontBackView = self.bodyPartsFrontBackView else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Keep a small delay to let let the updated selection get rendered before snapshotting.
            // Generate an image from presented bodyPartsFrontBackTextView
            bodyPartsFrontBackView.snapshot { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let image):
                    if self.snapshotFromPresentedFrontBackView == nil {
                        let snapshotFromPresentedFrontBackView = UIImageView(image: image)
                        snapshotFromPresentedFrontBackView.contentMode = .scaleAspectFit
                        self.view.addSubview(snapshotFromPresentedFrontBackView)
                        snapshotFromPresentedFrontBackView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            snapshotFromPresentedFrontBackView.topAnchor.constraint(equalTo: bodyPartsFrontBackView.bottomAnchor, constant: 8),
                            snapshotFromPresentedFrontBackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
                            snapshotFromPresentedFrontBackView.bottomAnchor.constraint(equalTo: self.showBodyPartPicker.topAnchor, constant: -8),
                            snapshotFromPresentedFrontBackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45)
                        ])
                        self.snapshotFromPresentedFrontBackView = snapshotFromPresentedFrontBackView
                    } else {
                        self.snapshotFromPresentedFrontBackView?.image = image
                    }
                case .failure(let failure):
                    self.snapshotFromPresentedFrontBackView = nil
                    self.snapshotFromPresentedFrontBackView?.removeFromSuperview()
                    print(failure)
                }
            }
        }
        
        // Generate an image with no WGBodyPartPickerFrontBackView shown in the UI.
        let hiddenViewForSnapshot = WGBodyPartPickerFrontBackView(preselect: bodyParts.keys, language: L.str("LANGUAGE_CODE"), gender: .female, backgroundColor: self.backgroundColor, bodyMapColor: nil, primaryColor: self.woundGeniusPresenter.primaryButtonColor, localization: self.woundGeniusPresenter)
        hiddenViewForSnapshot.snapshot { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                if self.snapshotFromHiddenFrontBackView == nil {
                    let snapshotFromHiddenFrontBackView = UIImageView(image: image)
                    snapshotFromHiddenFrontBackView.contentMode = .scaleAspectFit
                    snapshotFromHiddenFrontBackView.layer.cornerRadius = 8
                    snapshotFromHiddenFrontBackView.layer.borderColor = UIColor.black.cgColor
                    snapshotFromHiddenFrontBackView.layer.borderWidth = 1
                    self.view.addSubview(snapshotFromHiddenFrontBackView)
                    snapshotFromHiddenFrontBackView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        snapshotFromHiddenFrontBackView.topAnchor.constraint(equalTo: bodyPartsFrontBackView.bottomAnchor, constant: 8),
                        snapshotFromHiddenFrontBackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
                        snapshotFromHiddenFrontBackView.bottomAnchor.constraint(equalTo: self.showBodyPartPicker.topAnchor, constant: -8),
                        snapshotFromHiddenFrontBackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45)
                    ])
                    self.snapshotFromHiddenFrontBackView = snapshotFromHiddenFrontBackView
                } else {
                    self.snapshotFromHiddenFrontBackView?.image = image
                }
            case .failure(let failure):
                self.snapshotFromHiddenFrontBackView = nil
                self.snapshotFromHiddenFrontBackView?.removeFromSuperview()
                print(failure)
            }
        }
    }
}
