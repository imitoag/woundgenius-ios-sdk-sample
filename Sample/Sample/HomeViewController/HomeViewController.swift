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
import FileBrowser

class HomeViewController: UIViewController {
    
    private lazy var woundGeniusFlowPresenter: MyWoundGeniusPresenter = {
        MyWoundGeniusPresenter(completion: { [weak self] captureResults in
            guard let self = self else { return }
            self.series.append(Series(captureResults: captureResults))
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
    
    /** Core Module: A button to show Body Part Picker */
    private let showBodyPartPicker = UIButton(frame: .zero)
    
    /** Core Module: A button to show Body Part Picker */
    private let showV1BodyPartPicker = UIButton(frame: .zero)
    
    /** Core Module: TableView is showing the captured results. And provides the showcase - how to show the measurement results with available viewers. */
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    /** Core Module: Store the Series - set of Capture Results captured by WoundGenius. */
    private var series = [Series]()
    
    /** Universal Body Part Picker Results */
    private var pickedUBodyParts: [UBPPSection]?
    
    /** No need to integrate this in client apps. Integrated to handle the case when the license key is modified during single app session. Relevant only for Sample app. */
    private var lastUsedLicenseKey: String?
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        if let appVersion = appVersion, let buildVersion = buildVersion {
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
        
        /* START CAPTURING BUTTON */
        startCapturing.translatesAutoresizingMaskIntoConstraints = false
        startCapturing.addTarget(self, action: #selector(launchCamera), for: .touchUpInside)
        startCapturing.backgroundColor = UINavigationBar.appearance().tintColor
        startCapturing.tintColor = .white
        startCapturing.setTitle("Start Capturing", for: .normal)
        startCapturing.layer.cornerRadius = 5
        startCapturing.layer.masksToBounds = true
        self.view.addSubview(startCapturing)
        NSLayoutConstraint.activate([
            startCapturing.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            startCapturing.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            startCapturing.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        /* SHOW Universal BODY PART PICKER */
        showBodyPartPicker.translatesAutoresizingMaskIntoConstraints = false
        showBodyPartPicker.addTarget(self, action: #selector(startBodyPartPicker), for: .touchUpInside)
        showBodyPartPicker.backgroundColor = startCapturing.backgroundColor
        showBodyPartPicker.setTitle("Body Part Picker", for: .normal)
        showBodyPartPicker.tintColor = UINavigationBar.appearance().tintColor
        showBodyPartPicker.layer.cornerRadius = 5
        showBodyPartPicker.layer.masksToBounds = true
        self.view.addSubview(showBodyPartPicker)
        
        NSLayoutConstraint.activate([
            showBodyPartPicker.topAnchor.constraint(equalTo: startCapturing.bottomAnchor, constant: 10),
            showBodyPartPicker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            showBodyPartPicker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            showBodyPartPicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            showBodyPartPicker.heightAnchor.constraint(equalToConstant: 40)
        ])
        
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
        
        let bpPickerVC = UBPPickerViewController(preselect: self.pickedUBodyParts?
            .flatMap({ $0.items })
            .map({ $0.itemId }),
                                                 languageISO2Alpha: L.str("LANGUAGE_CODE"),
                                                 gender: .female,
                                                 localization: self.woundGeniusFlowPresenter, devLogs: { log in
            print(log)
        }) { [weak self] result in
            self?.pickedUBodyParts = result
        }
        self.present(bpPickerVC, animated: true)
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
        self.woundGeniusRouter?.startCapturing(over: self, completion: { _ in })
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
                config.text = "Mask"
                cell.contentConfiguration = config
            } else {
                // Fallback on earlier versions
            }
        case .photo(let photo):
            if #available(iOS 14.0, *) {
                var config = cell.defaultContentConfiguration()
                config.image = photo.preview
                config.text = "Photo"
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
                    config.image = measurement.image.outlineAndDrawWidthLength(result: measurement)
                }
                config.text = "Measurement"
                cell.contentConfiguration = config
            } else {
                // Fallback on earlier versions
            }
        }
        cell.imageView?.contentMode = .scaleAspectFit
        return cell
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
        case .image(let image):
            let details = MeasurementDetailsController(style: tableViewStyle,
                                                       image: image.image,
                                                       mediaManager: ImitoMeasureMediaManager(),
                                                       isRightButtonShown: false,
                                                       outlines: nil,
                                                       isDepthOrHeightInputEnabled: false,
                                                       title: "",
                                                       subtitle: "",
                                                       config: MyWoundGeniusPresenter(completion: {_ in }),
                                                       willDisappear: nil)
            self.navigationController?.pushViewController(details, animated: true)
        case .photo(let photo):
            let details = MeasurementDetailsController(style: tableViewStyle,
                                                       image: photo.preview,
                                                       mediaManager: ImitoMeasureMediaManager(),
                                                       isRightButtonShown: false,
                                                       outlines: nil,
                                                       isDepthOrHeightInputEnabled: false,
                                                       title: "",
                                                       subtitle: "",
                                                       config: MyWoundGeniusPresenter(completion: {_ in }),
                                                       willDisappear: nil)
            self.navigationController?.pushViewController(details, animated: true)
        case .measurement(let measurement):
            let outlines = measurement.outlines.map {
                MeasuredOutline(points: $0.points,
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
                                                           mediaManager: ImitoMeasureMediaManager(),
                                                           isRightButtonShown: false,
                                                           outlines: outlines,
                                                           mlOutlines: nil,
                                                           isDepthOrHeightInputEnabled: false,
                                                           config: MyWoundGeniusPresenter(completion: {_ in }),
                                                           title: "",
                                                           subtitle: "")
                self.navigationController?.pushViewController(summary, animated: true)
            } else {
                let details = MeasurementDetailsController(style: tableViewStyle,
                                                           image: measurement.image,
                                                           mediaManager: ImitoMeasureMediaManager(),
                                                           isRightButtonShown: false,
                                                           outlines: outlines,
                                                           isDepthOrHeightInputEnabled: false,
                                                           title: "",
                                                           subtitle: "",
                                                           config: MyWoundGeniusPresenter(completion: {_ in }),
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
    
    func showWhatsNewIfNeeded() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        
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
        
        let config = MyWoundGeniusPresenter(completion: {_ in })
        
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
