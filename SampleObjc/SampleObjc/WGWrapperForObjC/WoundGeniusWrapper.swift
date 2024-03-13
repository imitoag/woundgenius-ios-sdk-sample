//
//  WoundGeniusWrapper.swift
//  SampleObjc
//
//  Created by Eugene Naloiko on 11.03.2024.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit
import AVFoundation
import WoundGenius
import AVKit

@objc protocol WoundGeniusWrapperDelegate: NSObjectProtocol {
    func newDataCaptured()
}

class WoundGeniusWrapper: NSObject {
    
    @objc weak var delegate: WoundGeniusWrapperDelegate?
    
    @objc var allFeatures: [String] = Feature.allCases.map({ $0.rawValue })
    
    /** Core Module: Store the Series - set of Capture Results captured by WoundGenius. */
    private var series = [Series]()
    
    lazy var router: WGRouter = {
        let woundGeniusFlowPresenter = MyWoundGeniusPresenter(completion: { [weak self] captureResults in
            guard let self = self else { return }
            self.series.append(Series(captureResults: captureResults))
            self.router.stopCapturing()
            self.delegate?.newDataCaptured()
        })
        
        return WGRouter(presenter: woundGeniusFlowPresenter)
    }()
        
    override init() {
        WG.activate(licenseKey: "YOUR LICENSE KEY HERE HERE FOR YOUR BUNDLE ID")
        
        UINavigationBar.appearance().tintColor = WGConstants.Color.red // This should be configured in AppDelegate by your app.
    }
    
    /// ObjC enums support only Integer enums, thus this feature checking if it is available by the license should be wrapped.
    @objc func isAvailable(feature: String) -> Bool {
        guard let feature = Feature(rawValue: feature) else { return false }
        return WG.isAvailable(feature: feature)
    }
    
    @objc func startCapturing(over: UIViewController) {
        self.router.startCapturing(over: over)
    }
    
    @objc func numberOfSections() -> Int {
        return self.series.count
    }
    
    @objc func numberOfItems(section: Int) -> Int {
        return self.series[section].captureResults.count
    }
    
    @objc func imageFor(section: Int, row: Int) -> UIImage {
        let captureResult = self.series[section].captureResults[row]
        if let photoCaptureResult = captureResult as? PhotoCaptureResult {
            return photoCaptureResult.preview
        } else if let imageCaptureResult = captureResult as? ImageCaptureResult {
            return imageCaptureResult.image
        } else if let measurementCaptureResult = captureResult as? MeasurementResult {
            if measurementCaptureResult.outlines.contains(where: { $0.cluster == .stoma }) {
                return measurementCaptureResult
                    .image
                    .draw(outlines: measurementCaptureResult.outlines,
                          drawFullAreaLabel: false,
                          drawWidthLength: false,
                          drawDiameter: true,
                          displayedIndexes: nil)
            } else {
                return measurementCaptureResult.image.outlineAndDrawWidthLength(result: measurementCaptureResult)
            }
        } else if let videoCaptureResult = captureResult as? VideoCaptureResult {
            return videoCaptureResult.preview
        } else {
            return UIImage(named: "AppIcon")! // Stub for unprocessed cases.
        }
    }
    
    @objc func descriptionFor(section: Int, row: Int) -> String {
        let captureResult = self.series[section].captureResults[row]
        if let photoCaptureResult = captureResult as? PhotoCaptureResult {
            return "Photo"
        } else if let imageCaptureResult = captureResult as? ImageCaptureResult {
            return "Image"
        } else if let measurementCaptureResult = captureResult as? MeasurementResult {
            if measurementCaptureResult.outlines.contains(where: { $0.cluster == .stoma }) {
                return "Stoma Measurement"
            } else {
                return "Wound Measurement"
            }
        } else if let videoCaptureResult = captureResult as? VideoCaptureResult {
            return "Video"
        } else {
            return "Other"
        }
    }
    
    @objc func showMedia(section: Int, row: Int, over: UIViewController) {
        // Define the style for the Measurement Summary, or Measurement Details Table View.
        var tableViewStyle = UITableView.Style.grouped
        if #available(iOS 13.0, *) {
            tableViewStyle = .insetGrouped
        }
        
        let series = series[section]
        
        if let photoCaptureResult = series.captureResults[row] as? PhotoCaptureResult {
            let details = MeasurementDetailsController(style: tableViewStyle,
                                                       image: photoCaptureResult.preview,
                                                       mediaManager: ImitoMeasureMediaManager(),
                                                       isRightButtonShown: false,
                                                       outlines: nil,
                                                       isDepthOrHeightInputEnabled: false,
                                                       title: "",
                                                       subtitle: "",
                                                       willDisappear: nil)
            over.navigationController?.pushViewController(details, animated: true)
        } else if let imageCaptureResult = series.captureResults[row] as? ImageCaptureResult {
            let details = MeasurementDetailsController(style: tableViewStyle,
                                                       image: imageCaptureResult.image,
                                                       mediaManager: ImitoMeasureMediaManager(),
                                                       isRightButtonShown: false,
                                                       outlines: nil,
                                                       isDepthOrHeightInputEnabled: false,
                                                       title: "",
                                                       subtitle: "",
                                                       willDisappear: nil)
            over.navigationController?.pushViewController(details, animated: true)
        } else if let measurement = series.captureResults[row] as? MeasurementResult {
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
                over.navigationController?.pushViewController(summary, animated: true)
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
                over.navigationController?.pushViewController(details, animated: true)
            }
        } else if let video = series.captureResults[row] as? VideoCaptureResult {
            guard let url = ImitoCameraFileManager.documentPathForExistingFile(video.videoNameExt) else { return }
            let player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            over.present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        }
    }
}
