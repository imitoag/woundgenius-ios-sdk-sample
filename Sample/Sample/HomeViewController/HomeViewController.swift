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

class HomeViewController: UIViewController {
    
    // MARK: Properties
    
    /** Initiate the woundGeniusFlow instace with presenter and the license key. */
    private lazy var woundGeniusFlow: WoundGeniusFlow = {
        return self.woundGeniusFlowInstance()
    }()
    
    /** Core Module: A button to launch WoundGenius Capturing */
    private let startCapturing = UIButton(frame: .zero)
    
    /** Core Module: A button to show Body Part Picker */
    private let showBodyPartPicker = UIButton(frame: .zero)
    
    /** Core Module: TableView is showing the captured results. And provides the showcase - how to show the measurement results with available viewers. */
    private let tableView = UITableView(frame: .zero)
    
    /** Core Module: Store the Series - set of Capture Results captured by WoundGenius. */
    private var series = [Series]()
    
    /** Body Part Picked, while picker is initiated by Core Module */
    private var pickedBodyPart: BodyPartPickerResult?
    
    /** No need to integrate this in client apps. Integrated to handle the case when the license key is modified during single app session. Relevant only for Sample app. */
    private var lastUsedLicenseKey: String?
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.title = "WoundGenius (\(appVersion))"
        } else {
            self.title = "WoundGenius"
        }

        self.view.backgroundColor = .white
                
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
        tableView.backgroundColor = .white
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
        
        /* SHOW BODY PART PICKER */
        showBodyPartPicker.translatesAutoresizingMaskIntoConstraints = false
        showBodyPartPicker.addTarget(self, action: #selector(startBodyPartPicker), for: .touchUpInside)
        showBodyPartPicker.backgroundColor = startCapturing.backgroundColor
        showBodyPartPicker.setTitle("Pick Body Part", for: .normal)
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
        if UserDefaults.standard.value(forKey: SettingKey.maxNumberOfMediaInt.rawValue) == nil {
            UserDefaults.standard.setValue(1, forKey: SettingKey.maxNumberOfMediaInt.rawValue)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
         This check is not needed for client apps to implement.
         It is done to handle the case where the license key is getting modified during single app usage session.
         For constant license key - initiate woundGeniusFlow once.
         */
        if self.lastUsedLicenseKey != UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue) {
            self.lastUsedLicenseKey = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue)
            self.woundGeniusFlow = self.woundGeniusFlowInstance()
        }
    }
}

// MARK: - Button Actions

extension HomeViewController {
    
    /* WoundGenius: To use only body part picker feature. */
    @objc func startBodyPartPicker() {
        guard let licenseKey = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue), !licenseKey.isEmpty else {
            UIUtils.shared.showOKAlert("No License Key", message: "Please configure the license key in Settings, or contact imito AG support to get it.")
            return
        }
        
        woundGeniusFlow.startBodyPartPicker(over: self, preselect: self.pickedBodyPart) { [weak self] bodyPart in
            DispatchQueue.main.async {
                self?.pickedBodyPart = bodyPart
                self?.showBodyPartPicker.setTitle("Pick Body Part (\(bodyPart?.hashtag_en ?? "-"))", for: .normal)
            }
        }
    }
    
    /* WundGenius: To launch the Camera */
    @objc func launchCamera() {
        guard let licenseKey = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue), !licenseKey.isEmpty else {
            UIUtils.shared.showOKAlert("No License Key", message: "Please configure the license key in Settings, or contact imito AG support to get it.")
            return
        }
        self.woundGeniusFlow.startCapturing(over: self)
    }
    
    /* Core Module: Settings */
    @objc func openSettings() {
        performSegue(withIdentifier: "showSettings", sender: nil)
    }
}

// MARK: - WoundGeniusFlow instance generator

extension HomeViewController {
    
    private func woundGeniusFlowInstance() -> WoundGeniusFlow {
        let woundGeniusFlowPresenter = MyWoundGeniusPresenter(completion: { [weak self] captureResults in
            guard let self = self else { return }
            self.series.append(Series(captureResults: captureResults))
            (self.tableView.tableHeaderView as? ChartView)?.updateChartData(series: self.series, tableView: self.tableView)
            self.tableView.reloadData()
            self.woundGeniusFlow.stopCapturing()
        })
        
        return WoundGeniusFlow(licenseKey: UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue) ?? "",
                               presenter: woundGeniusFlowPresenter)
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
        if let photoCaptureResult = captureResult as? PhotoCaptureResult {
            if #available(iOS 14.0, *) {
                var config = cell.defaultContentConfiguration()
                config.image = photoCaptureResult.preview
                config.text = "Photo"
                cell.contentConfiguration = config
            } else {
                // Fallback on earlier versions
            }
        } else if let imageCaptureResult = captureResult as? ImageCaptureResult {
            if #available(iOS 14.0, *) {
                var config = cell.defaultContentConfiguration()
                config.image = imageCaptureResult.image
                config.text = "Mask"
                cell.contentConfiguration = config
            } else {
                // Fallback on earlier versions
            }
        } else if let measurementCaptureResult = captureResult as? MeasurementResult {
            if #available(iOS 14.0, *) {
                var config = cell.defaultContentConfiguration()
                if measurementCaptureResult.outlines.contains(where: { $0.cluster == .stoma }) {
                    config.image = measurementCaptureResult.image.draw(outlines: measurementCaptureResult.outlines, drawFullAreaLabel: false, drawWidthLength: false, drawDiameter: true, displayedIndexes: nil)
                } else {
                    config.image = measurementCaptureResult.image.outlineAndDrawWidthLength(result: measurementCaptureResult)
                }
                config.text = "Measurement"
                cell.contentConfiguration = config
            } else {
                // Fallback on earlier versions
            }
        } else if let videoCaptureResult = captureResult as? VideoCaptureResult {
            if #available(iOS 14.0, *) {
                var config = cell.defaultContentConfiguration()
                config.image = videoCaptureResult.preview
                config.text = "Video"
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
        
        if let photoCaptureResult = series.captureResults[indexPath.row] as? PhotoCaptureResult {
            let details = MeasurementDetailsController(style: tableViewStyle,
                                                       image: photoCaptureResult.preview,
                                                       mediaManager: ImitoMeasureMediaManager(),
                                                       isRightButtonShown: false,
                                                       outlines: nil,
                                                       isDepthOrHeightInputEnabled: false,
                                                       title: "",
                                                       subtitle: "",
                                                       willDisappear: nil)
            self.navigationController?.pushViewController(details, animated: true)
        } else if let imageCaptureResult = series.captureResults[indexPath.row] as? ImageCaptureResult {
            let details = MeasurementDetailsController(style: tableViewStyle,
                                                       image: imageCaptureResult.image,
                                                       mediaManager: ImitoMeasureMediaManager(),
                                                       isRightButtonShown: false,
                                                       outlines: nil,
                                                       isDepthOrHeightInputEnabled: false,
                                                       title: "",
                                                       subtitle: "",
                                                       willDisappear: nil)
            self.navigationController?.pushViewController(details, animated: true)
        } else if let measurement = series.captureResults[indexPath.row] as? MeasurementResult {
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
                let summary = MeasurementSummaryController(style: tableViewStyle,
                                                           image: measurement.image,
                                                           mediaManager: ImitoMeasureMediaManager(),
                                                           isRightButtonShown: false,
                                                           outlines: outlines,
                                                           isDepthOrHeightInputEnabled: false,
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
                                                           willDisappear: nil)
                self.navigationController?.pushViewController(details, animated: true)
            }
        } else if let video = series.captureResults[indexPath.row] as? VideoCaptureResult {
            guard let url = ImitoCameraFileManager.documentPathForExistingFile(video.videoNameExt) else { return }
            let player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        }
    }
}
