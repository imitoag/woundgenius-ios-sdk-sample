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
    private lazy var woundSDKFlow: WoundGeniusFlow = {
        let woundSDKFlowPresenter = MyWoundSDKPresenter(completion: { [weak self] captureResults in
            guard let self = self else { return }
            self.series.append(Series(captureResults: captureResults))
            (self.tableView.tableHeaderView as? ChartView)?.updateChartData(series: self.series, tableView: self.tableView)
            self.tableView.reloadData()
            self.woundSDKFlow.stopCapturing()
        })
        return WoundGeniusFlow(licenseKey: UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue) ?? "",
                               presenter: woundSDKFlowPresenter)
    }()
    
    /** Launch WoundSDK Capturing */
    private let startCapturing = UIButton(frame: .zero)
    
    /** Show Body Part Picker */
    private let showBodyPartPicker = UIButton(frame: .zero)
    
    /** TableView is showing the captured results. And provides the showcase - how to show the measurement results with available viewers. */
    private let tableView = UITableView(frame: .zero)
    
    /** Store the captured data */
    private var series = [Series]()
    
    /** Body Part Picked from Core Module */
    private var pickedBodyPart: BodyPartPickerResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "WoundSDK"
        self.view.backgroundColor = .white
        
        /* DEFAULT SETTINGS FOR FEATURES */
        if UserDefaults.standard.bool(forKey: SettingKey.photoModeEnabled.rawValue) == false &&
            UserDefaults.standard.bool(forKey: SettingKey.videoModeEnabled.rawValue) == false &&
            UserDefaults.standard.bool(forKey: SettingKey.markerModeEnabled.rawValue) == false &&
            UserDefaults.standard.bool(forKey: SettingKey.rulerModeEnabled.rawValue) == false {
            UserDefaults.standard.set(true, forKey: SettingKey.markerModeEnabled.rawValue)
            UserDefaults.standard.set(true, forKey: SettingKey.rulerModeEnabled.rawValue)
        }
        
        if UserDefaults.standard.value(forKey: SettingKey.maxNumberOfMediaInt.rawValue) == nil {
            UserDefaults.standard.set(1, forKey: SettingKey.maxNumberOfMediaInt.rawValue)
        }
        
        if UserDefaults.standard.value(forKey: SettingKey.multipleOutlinesPerImageEnabled.rawValue) == nil {
            UserDefaults.standard.set(true, forKey: SettingKey.multipleOutlinesPerImageEnabled.rawValue)
        }
        
        UserDefaults.standard.set(true, forKey: SettingKey.localStorageMediaEnabled.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKey.bodyPartPickerOnCapturingEnabled.rawValue)
        UserDefaults.standard.set(true, forKey: SettingKey.frontalCameraEnabled.rawValue) // False by default
        
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
    }
    
    @objc func startBodyPartPicker() {
        guard let licenseKey = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue), !licenseKey.isEmpty else {
            UIUtils.shared.showOKAlert("No License Key", message: "Please configure the license key in Settings, or contact imito AG support to get it.")
            return
        }
        woundSDKFlow.startBodyPartPicker(over: self, preselect: self.pickedBodyPart) { [weak self] bodyPart in
            DispatchQueue.main.async {
                self?.pickedBodyPart = bodyPart
                self?.showBodyPartPicker.setTitle("Pick Body Part (\(bodyPart?.hashtag_en ?? "-"))", for: .normal)
            }
        }
    }
    
    @objc func launchCamera() {
        guard let licenseKey = UserDefaults.standard.string(forKey: SettingKey.licenseKey.rawValue), !licenseKey.isEmpty else {
            UIUtils.shared.showOKAlert("No License Key", message: "Please configure the license key in Settings, or contact imito AG support to get it.")
            return
        }
        self.woundSDKFlow.startCapturing(over: self)
    }
    
    @objc func openSettings() {
        performSegue(withIdentifier: "showSettings", sender: nil)
    }
}

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
        } else if let measurementCaptureResult = captureResult as? MeasurementResult {
            if #available(iOS 14.0, *) {
                var config = cell.defaultContentConfiguration()
                config.image = measurementCaptureResult.image.outlineAndDrawWidthLength(result: measurementCaptureResult)
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
        if let photoCaptureResult = series[indexPath.section].captureResults[indexPath.row] as? PhotoCaptureResult {
            let measurementViewer = MeasurementOverviewController(style: .grouped,
                                                                  image: photoCaptureResult.preview,
                                                                  mediaManager: ImitoMeasureMediaManager(),
                                                                  isRightButtonShown: false,
                                                                  outlines: nil,
                                                                  isDepthInputEnabled: false,
                                                                  title: "",
                                                                  subtitle: "",
                                                                  isStoma: false)
            self.navigationController?.pushViewController(measurementViewer, animated: true)
        }
        else if let measurement = series[indexPath.section].captureResults[indexPath.row] as? MeasurementResult {
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
            let measurementViewer = MeasurementOverviewController(style: .grouped,
                                                                  image: measurement.image, mediaManager: ImitoMeasureMediaManager(),
                                                                  isRightButtonShown: false,
                                                                  outlines: outlines,
                                                                  isDepthInputEnabled: false,
                                                                  title: "",
                                                                  subtitle: "",
                                                                  isStoma: false)
            self.navigationController?.pushViewController(measurementViewer, animated: true)
        } else if let video = series[indexPath.section].captureResults[indexPath.row] as? VideoCaptureResult {
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

