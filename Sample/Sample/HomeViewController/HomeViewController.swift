//
//  HomeViewController.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.12.2022.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit
import AVFoundation
import AVKit
import WoundGenius
import SwiftUI
import FileBrowser

class HomeViewController: UIViewController {
    
    private lazy var woundGeniusFlowPresenter: MyWoundGeniusPresenter = {
        MyWoundGeniusPresenter(completion: { [weak self] captureResults in
            guard let self = self else { return }
            self.series.append(Series(captureResults: captureResults, formsModel: nil))
            (self.tableView.tableHeaderView as? ChartView)?.updateChartData(series: self.series, tableView: self.tableView)
            self.tableView.reloadData()
            self.woundGeniusRouter?.stopCapturing()
        })
    }()
        
    // MARK: Properties
    
    /** Initiate the woundGeniusFlow instace with presenter. */
    private var woundGeniusRouter: WGRouter?
    
    /** Core Module: A button to launch WoundGenius Capturing */
    private let startCapturing = UIButton(frame: .zero)
    
    /** Core Module: A button to launch WoundGenius 3D Capturing */
    private let start3DCapturing = UIButton(frame: .zero)
    
    /** Core Module: A button to launch WoundGenius 3D Capturing */
    private let displayMeasuremntResults = UIButton(frame: .zero)
    
    /** Core Module: A button to show Body Part Picker */
    private let showBodyPartPicker = UIButton(frame: .zero)
    
    /** Core Module: A button to show Body Part Picker */
    private let showV1BodyPartPicker = UIButton(frame: .zero)
    
    /** A button to launch Default Assessment + CDS flow */
    private lazy var startDefaultAssessmentCDS: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(launchDefaultAssessmentCDS), for: .touchUpInside)
        button.backgroundColor = UINavigationBar.appearance().tintColor
        button.tintColor = .white
        button.setTitle("Default Assessment + CDS", for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    
    /** Vertical stack view for bottom action buttons */
    private let bottomButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /** Core Module: TableView is showing the captured results. And provides the showcase - how to show the measurement results with available viewers. */
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    /** Core Module: Store the Series - set of Capture Results captured by WoundGenius. */
    private var series = [Series]()
        
    /** No need to integrate this in client apps. Integrated to handle the case when the license key is modified during single app session. Relevant only for Sample app. */
    private var lastUsedLicenseKey: String?
    
    private var ifAppSupportDevice: Bool = false
    
    private let standaloneAssessmentsManager = StandaloneAssessmentManager()
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        if let appVersion = appVersion, let buildVersion = buildVersion {
            #if DEBUG
            assert(WGConstants.sdkVersion == appVersion, "⚠️⚠️⚠️ Reminder: The App Version and the SDK Version should match in most of the cases during Debugging.\nDisable this assert only when it's required to test non-matching Sample App and SDK version.")
            #endif
            self.title = "WoundGenius: \(WGConstants.sdkVersion). Build: \(appVersion).\(buildVersion)."
        } else {
            self.title = "WoundGenius v\(WGConstants.sdkVersion)"
        }
        
        /* RIGHT BAR BUTTON ITEM */
        if #available(iOS 16.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "gear"), target: self, action: #selector(openSettings))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(openSettings))
        }
        
        /* TABLE VIEW */
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = ChartView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .imiSystemGroupedBackground()
        self.view.addSubview(tableView)
        tableView.register(CaptureResultTableViewCell.self, forCellReuseIdentifier: String(describing: CaptureResultTableViewCell.self))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        //Hide 3D scanning button
        //        start3DCapturing.isHidden = false
        
        /* BOTTOM BUTTONS STACK VIEW */
        startCapturing.isHidden = false
        startCapturing.addTarget(self, action: #selector(launchCamera), for: .touchUpInside)
        startCapturing.backgroundColor = UINavigationBar.appearance().tintColor
        startCapturing.tintColor = .white
        startCapturing.setTitle("Start Capturing", for: .normal)
        startCapturing.layer.cornerRadius = 5
        startCapturing.layer.masksToBounds = true
        startCapturing.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        showBodyPartPicker.isHidden = false
        showBodyPartPicker.addTarget(self, action: #selector(startBodyPartPicker), for: .touchUpInside)
        showBodyPartPicker.backgroundColor = startCapturing.backgroundColor
        showBodyPartPicker.setTitle("Body Part Picker", for: .normal)
        showBodyPartPicker.tintColor = UINavigationBar.appearance().tintColor
        showBodyPartPicker.layer.cornerRadius = 5
        showBodyPartPicker.layer.masksToBounds = true
        showBodyPartPicker.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        bottomButtonsStackView.addArrangedSubview(startCapturing)
        bottomButtonsStackView.addArrangedSubview(showBodyPartPicker)
        self.view.addSubview(bottomButtonsStackView)
        NSLayoutConstraint.activate([
            bottomButtonsStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            bottomButtonsStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            bottomButtonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
#if SAMPLE3D
        /* DISPLAY MEASUREMENT RESULT */
        if #available(iOS 18.0, *) {
            displayMeasuremntResults.addTarget(self, action: #selector(display3DMeasurementResult), for: .touchUpInside)
        }
        displayMeasuremntResults.backgroundColor = UINavigationBar.appearance().tintColor
        displayMeasuremntResults.tintColor = .white
        displayMeasuremntResults.setTitle("Display Measurement Result 3D", for: .normal)
        displayMeasuremntResults.layer.cornerRadius = 5
        displayMeasuremntResults.layer.masksToBounds = true
        displayMeasuremntResults.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        if #available(iOS 18, *) {
            /* START 3D CAPTURING BUTTON */
            start3DCapturing.addTarget(self, action: #selector(open3DCapturing), for: .touchUpInside)
            start3DCapturing.backgroundColor = UINavigationBar.appearance().tintColor
            start3DCapturing.tintColor = .white
            start3DCapturing.setTitle("Start 3D Capturing", for: .normal)
            start3DCapturing.layer.cornerRadius = 5
            start3DCapturing.layer.masksToBounds = true
            start3DCapturing.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            bottomButtonsStackView.insertArrangedSubview(start3DCapturing, at: 0)
        }
        bottomButtonsStackView.insertArrangedSubview(displayMeasuremntResults, at: start3DCapturing.superview != nil ? 1 : 0)
#endif
        /* SETUP DEFAULT VALUES */
        if UserDefaults.standard.value(forKey: SettingKey.minNumberOfMediaInt.rawValue) == nil {
            UserDefaults.standard.setValue(1, forKey: SettingKey.minNumberOfMediaInt.rawValue)
        }
        
        if UserDefaults.standard.value(forKey: SettingKey.maxNumberOfMediaInt.rawValue) == nil {
            UserDefaults.standard.setValue(1, forKey: SettingKey.maxNumberOfMediaInt.rawValue)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.woundGeniusRouter == nil {
            self.woundGeniusRouter = self.woundGeniusRouterInstance()
        }
        
        configureDefaultAssessmentCDSLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.woundGeniusRouter = nil // Keep WGRouter object in memory to keep the MLModels initialized, Body Part Picker. Nullifying it here to test that memory related to WoundGenius is getting released.
#if !targetEnvironment(simulator)
        WoundGeniusTFLiteExtension.shared.cleanup()
#endif
        
        self.showWhatsNewIfNeeded()                
    }
}

// MARK: - Button Actions

extension HomeViewController {
    
    /* WoundGenius: To use only body part picker feature. */
    @objc func startBodyPartPicker() {
        if self.woundGeniusRouter == nil {
            self.woundGeniusRouter = self.woundGeniusRouterInstance()
        }
        
        guard let licenseKey = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue), !licenseKey.isEmpty else {
            UIUtils.showOKAlert("No License Key", message: "Please configure the license key in Settings, or contact imito AG support to get it.")
            return
        }
        
        let bodyPartPickerSampleVC = SampleBodyPartPickerViewController(woundGeniusPresenter: self.woundGeniusFlowPresenter)
        self.navigationController?.pushViewController(bodyPartPickerSampleVC, animated: true)
    }
    
    /* WundGenius: To launch the Camera */
    @objc func launchCamera() {
        if self.woundGeniusRouter == nil {
            self.woundGeniusRouter = self.woundGeniusRouterInstance()
        }
        
        guard let licenseKey = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue), !licenseKey.isEmpty else {
            UIUtils.showOKAlert("No License Key", message: "Please configure the license key in Settings, or contact imito AG support to get it.")
            return
        }
        self.woundGeniusRouter?.startCapturing(over: self) { success in
            
        }
    }
    
    /* WoundGenius: To launch Default Assessment + CDS */
    @objc func launchDefaultAssessmentCDS() {
        if self.woundGeniusRouter == nil {
            self.woundGeniusRouter = self.woundGeniusRouterInstance()
        }
        
        guard let licenseKey = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue), !licenseKey.isEmpty else {
            UIUtils.showOKAlert("No License Key", message: "Please configure the license key in Settings, or contact imito AG support to get it.")
            return
        }

        if #available(iOS 17.0, *) {
            self.woundGeniusRouter?.startDefaultStandaloneAssessment(over: self, assessmentManager: standaloneAssessmentsManager, completion: { [weak self] formsModel, captureResult in
                guard let self = self else { return }
                var captureResults = [CaptureResult]()
                if let captureResult = captureResult {
                    captureResults = [captureResult]
                } else {
                    captureResults = [.image(ImageCaptureResult(image: UIImage(systemName: "list.bullet.clipboard")?.withTintColor(.red, renderingMode: .alwaysOriginal)))]
                }
                self.series.append(Series(captureResults: captureResults, formsModel: formsModel))
                (self.tableView.tableHeaderView as? ChartView)?.updateChartData(series: self.series, tableView: self.tableView)
                self.tableView.reloadData()
            })
        }
    }
    
    @available(iOS 18.0, *)
    @objc func open3DCapturing() {
        if self.woundGeniusRouter == nil {
            self.woundGeniusRouter = self.woundGeniusRouterInstance()
        }
        
        guard let woundGeniusRouter = self.woundGeniusRouter else { return }
        
        if isDeviceSupported() {
                let contentView = ContentView().environment(AppDataModel.instance)
                
                let hostingController = UIHostingController(rootView: contentView)
                hostingController.modalPresentationStyle = .fullScreen
                self.present(hostingController, animated: true)
        } else {
            // Show alert if device is not supported
            let alert = UIAlertController(title: "Device Not Supported", message: "This device does not support 3D capturing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @available(iOS 18.0, *)
    @objc func display3DMeasurementResult() {
        if self.woundGeniusRouter == nil {
            self.woundGeniusRouter = self.woundGeniusRouterInstance()
        }
        
        guard let licenseKey = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue), !licenseKey.isEmpty else {
            UIUtils.showOKAlert("No License Key", message: "Please configure the license key in Settings, or contact imito AG support to get it.")
            return
        }
        self.woundGeniusRouter?.display3DMeasurementResult(over: self)
    }
    
    /* Core Module: Settings */
    @objc func openSettings() {
        performSegue(withIdentifier: "showSettings", sender: nil)
    }
}

// MARK: - WoundGeniusFlow instance generator

extension HomeViewController {
    
    private func woundGeniusRouterInstance() -> WGRouter {
        if let key = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue) {
            WG.activate(licenseKey: key)
        }
        
        let router = WGRouter(presenter: woundGeniusFlowPresenter)
        woundGeniusFlowPresenter.router = router
        
        return router
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        label.textColor = UIColor.black
        label.textAlignment = .center
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        label.text = dateFormatter.string(from: Date(timeIntervalSince1970: series[section].timestamp))
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return series.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return series[section].captureResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let captureResult = series[indexPath.section].captureResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CaptureResultTableViewCell.self), for: indexPath)
        let formsModelExists = series[indexPath.section].formsModel != nil
        switch captureResult {
        case .video(let video):
            if #available(iOS 14.0, *) {
                var config = cell.defaultContentConfiguration()
                config.image = video.preview
                config.text = "Video"
                cell.contentConfiguration = config
            } else {
                // Fallback on earlier versions
            }
        case .image(let image):
            if #available(iOS 14.0, *) {
                var config = cell.defaultContentConfiguration()
                config.image = image.image
                config.text = "Image" + (formsModelExists ? " + Form" : "")
                cell.contentConfiguration = config
            } else {
                // Fallback on earlier versions
            }
        case .photo(let photo):
            if #available(iOS 14.0, *) {
                var config = cell.defaultContentConfiguration()
                config.image = photo.preview
                config.text = "Photo" + (formsModelExists ? " + Form" : "")
                cell.contentConfiguration = config
            } else {
                // Fallback on earlier versions
            }
        case .measurement(let measurement):
            if #available(iOS 14.0, *) {
                var config = cell.defaultContentConfiguration()
                if measurement.outlines.contains(where: { $0.cluster == .stoma }) {
                    config.image = measurement.image.draw(outlines: measurement.outlines, drawFullAreaLabel: false, drawWidthLength: false, drawDiameter: true, config: MyWoundGeniusLokalizable(), displayedIndexes: nil)
                } else {
                    config.image = measurement.image.draw(outlines: measurement.outlines, drawFullAreaLabel: true, drawWidthLength: true, drawDiameter: false, config: MyWoundGeniusLokalizable(), displayedIndexes: nil)
                }
                config.text = "Measurement" + (formsModelExists ? " + Form" : "")
                cell.contentConfiguration = config
            } else {
                // Fallback on earlier versions
            }
        }
        cell.imageView?.contentMode = .scaleAspectFit
        if formsModelExists {
            cell.accessoryType = .detailButton
            cell.tintColor = .red
        } else {
            cell.accessoryType = .none
            cell.tintColor = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let formsModel = series[indexPath.section].formsModel else { return }
        let updatedModel = formsModel.withUpdatedResults()
        guard let jsonData = updatedModel.jsonEncodedData() else { return }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("formsModel.json")
        do {
            try jsonData.write(to: tempURL)
        } catch {
            print("Failed to write JSON file: \(error.localizedDescription)")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        self.present(activityVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Define the style for the Measurement Summary, or Measurement Details Table View.
        var tableViewStyle = UITableView.Style.grouped
        if #available(iOS 13.0, *) {
            tableViewStyle = .insetGrouped
        }
        
        let series = series[indexPath.section]
        
        switch series.captureResults[indexPath.row] {
        case .video(let video):
            guard let url = ImitoCameraFileManager.documentPathForExistingFile(video.videoNameExt) else { return }
            let player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        case .image(let result):
            let config = MyWoundGeniusPresenter(completion: {_ in })
            
            let details = MeasurementDetailsController(style: tableViewStyle,
                                                       image: result.image,
                                                       isRightButtonShown: false,
                                                       outlines: nil,
                                                       isDepthOrHeightInputEnabled: false,
                                                       title: "",
                                                       subtitle: "",
                                                       config: config,
                                                       willDisappear: nil)
            self.navigationController?.pushViewController(details, animated: true)
        case .photo(let result):
            let config = MyWoundGeniusPresenter(completion: {_ in })
            
            let details = MeasurementDetailsController(style: tableViewStyle,
                                                       image: result.preview,
                                                       isRightButtonShown: false,
                                                       outlines: nil,
                                                       isDepthOrHeightInputEnabled: false,
                                                       title: "",
                                                       subtitle: "",
                                                       config: config,
                                                       willDisappear: nil)
            self.navigationController?.pushViewController(details, animated: true)
        case .measurement(let measurement):
            let filteredOutlines = measurement.outlines.filter {
                if $0.cluster == .line {
                    return $0.points.count >= 2
                } else {
                    return $0.points.count >= 3
                }
            }
            let outlines = filteredOutlines.map {
                MeasuredOutline(
                    id: $0.id,
                    points: $0.points,
                    areaInCM: $0.areaInCM,
                    circumferenceInCM: $0.circumferenceInCM,
                    lengthInCM: $0.lengthInCM,
                    lengthStartPointPixels: $0.lengthStartPointPixels,
                    lengthEndPointPixels: $0.lengthEndPointPixels,
                    widthInCM: $0.widthInCM,
                    widthStartPointPixels: $0.widthStartPointPixels,
                    widthEndPointPixels: $0.widthEndPointPixels,
                    depthCM: $0.depthCM,
                    order: $0.order,
                    cluster: $0.cluster,
                    excluding: $0.excluding,
                    parentOutlineOrder: $0.parentOutlineOrder,
                    parentOutlineCluster: $0.parentOutlineCluster)
            }
            let config = MyWoundGeniusPresenter(completion: {_ in })
            config.isDepthOrHeightInputEnabled = false
            
            if outlines.filter({ $0.cluster.isSecondaryType }).count > 0 {
                // Use the outlines to get needed values out.
                // To get the tissue types and areas you as well can use the convenience method.
                let tissueTypesAreas = outlines.tissueTypesAreaCM2()
                print("===\ntissueTypesArea() Show Case:\n\(tissueTypesAreas)\n===")
                
                // To get the tissue types and their percentage of total wounds areas you as well can use the convenience method.
                let tissueTypesPercentage = outlines.tissueTypesPercentage()
                print("===\ntissueTypesPercentage() Show Case:\n\(tissueTypesPercentage)\n===")
                
                let summary = MeasurementSummaryController(style: tableViewStyle,
                                                           image: measurement.image,
                                                           isRightButtonShown: false,
                                                           outlines: outlines,
                                                           mlOutlines: nil,
                                                           isDepthOrHeightInputEnabled: false,
                                                           config: config,
                                                           title: "",
                                                           subtitle: "")
                self.navigationController?.pushViewController(summary, animated: true)
            } else {
                let details = MeasurementDetailsController(style: tableViewStyle,
                                                           image: measurement.image,
                                                           isRightButtonShown: false,
                                                           outlines: outlines,
                                                            isDepthOrHeightInputEnabled: false,
                                                           title: "",
                                                           subtitle: "",
                                                           config: config,
                                                           willDisappear: nil)
                self.navigationController?.pushViewController(details, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.series[indexPath.section].captureResults[indexPath.row].value.deleteRelatedFiles()
            self.series[indexPath.section].captureResults.remove(at: indexPath.row)
            if series[indexPath.section].captureResults.count == 0 {
                self.series.remove(at: indexPath.section)
            }
            self.tableView.reloadData()
            (self.tableView.tableHeaderView as? ChartView)?.updateChartData(series: self.series, tableView: self.tableView)
        }
    }
}

// MARK: Show What's New If Needed

extension HomeViewController {
    private func configureDefaultAssessmentCDSLayout() {
        guard WG.isAvailable(feature: .therapyCDS), #available(iOS 17.0, *) else {
            bottomButtonsStackView.removeArrangedSubview(startDefaultAssessmentCDS)
            startDefaultAssessmentCDS.removeFromSuperview()
            return
        }
        
        startDefaultAssessmentCDS.heightAnchor.constraint(equalToConstant: 40).isActive = true
        // Insert before the last item (showBodyPartPicker) to keep it above the picker
        let insertIndex = max(bottomButtonsStackView.arrangedSubviews.count - 1, 0)
        bottomButtonsStackView.insertArrangedSubview(startDefaultAssessmentCDS, at: insertIndex)
    }
    
    func showWhatsNewIfNeeded() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        
        let config = MyWoundGeniusPresenter(completion: {_ in })
        
        func present(key: String, userId: String?) -> Bool {
            let body = L.strWithPatterns(key)
            guard key != body else { return false } // The body doesn't exist in localization.
            guard WhatsNewViewController.canShow(htmlBodyKey: key, userId: userId) else {
                return false
            }
            let data = WhatsNewData(htmlBodyKey: key,
                                    htmlBody: L.strWithPatterns(body))
            let vc = WhatsNewViewController(data: data, config: config)
            self.present(vc, animated: true)
            return true
        }
        
        let iOSKey = "WHATS_NEW_\(appVersion)_iOS_HTML"
        let universalKey = "WHATS_NEW_\(appVersion)_HTML"
        //
        if present(key: iOSKey, userId: config.userId) {
            return // If there is iOS specific What's new defined. "WHATS_NEW_\(appVersion)_iOS_HTML" - try to show it, if not shown before.
        } else if present(key: universalKey, userId: config.userId) {
            return // If there is the value in localisation for "WHATS_NEW_\(appVersion)_HTML" - try to show it, if not shown before.
        }
    }
}

extension HomeViewController {
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let fileBrowser = FileBrowser()
            self.present(fileBrowser, animated: true, completion: nil)
        }
    }
}
