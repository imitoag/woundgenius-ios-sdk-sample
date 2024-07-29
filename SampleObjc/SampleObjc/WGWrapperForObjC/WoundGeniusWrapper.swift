//
//  WoundGeniusWrapper.swift
//  SampleObjc
//
//  Created by Eugene Naloiko on 11.03.2024.
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
        WG.activate(licenseKey: "eyJzaWciOiJRc0FQMVJoSUNIUWEwWTRLc3R0NmhRT3Z1dFlFSVwvYTlqUHJnM01xcGVEcFFtY1ZHNnh0K0o0TklRTnBHbFNXY2xINnQ1S0JBbXdSeUFEemwxK1lWd0dsVmZhRHR5VVdtUEN5KzNpWjdXdlVnbTE4eFNHTXV4YWFwM0dSaHNteWE3MzJpQ053V3dhakRNbmQwd001VUhrek9jRTJobXNEbDdTdHk5MFNnTDJON1BkNHMxcURsM0diS3BHdXFSSnFJNk1EZzQ3Z0h1ME1BN1BHVmRtelZ4NjZxcm1YRUx4R2l5UVhrdEtaSE01eHFTMVZud3JUMno3ZDFuVnprTitzdGduZ3Y0UzFnU3dkNUI3MFJKTlRvM2ltVW1qcFpkWEY3c3h1ZzAwT211U1VFR3BnWE5qb2pMVlIrVEIxWCtoXC9FZlZOMGxJK0F2SHdYd0djMlZGK3JxczZIa3E4a1ZydENFaEt5RWZSUkxLcWRBS0FibytvQWlYQjQ3ZlNhMWszeTB0RzdxOU1HWEljSXlUUEJjaUpiV0JncDRzbUp3UndWXC9qN3RsWGNtRzNqb1ZMaVd1Vzg0OUtGNml5NUo0Y2hHMHBWWUJBU3dGVXFJVXpyVk0yWGpWc0RuQ0VKQVRpT3g1SUZ5OVdQT1U5OWduSjBqdnc2dEFUdVRaZXZoTm5CWTQ4UzRmYjZyWkNoeUI3XC9YTDFUemV4Vks0bUlmVCtMSVorZjlkTkpXeXYxaFJRanA0MW1lUkpjNDhyUjcweEhGSW91YlAxaUdmWml1TkdadUZEdnd5Z2cxVzRMbm1ZbkZHeUZUK0FKTjZVNTd4RGl5UkJ4MkpRWkxXQkhxYUVkNnFxWE56ZG9lTHlXKzUwRUNWZ1U1cWMwNEtNWVFkNnhWcUJHRlVDYm9helE9IiwiYWxnIjoiMSIsImVuYyI6ImV5SmtZWFJoSWpwN2ZTd2lhVzVqYkhWa1pXUWlPbHQ3SW1sa0lqb2lhVzh1YVcxcGRHOHVkMjkxYm1SblpXNXBkWE11YzJGdGNHeGxJaXdpZEhsd1pTSTZJbUZ3Y0d4cFkyRjBhVzl1U1dRaWZTeDdJbWxrSWpvaWNHaHZkRzlEWVhCMGRYSnBibWNpTENKMGVYQmxJam9pWm1WaGRIVnlaVWxrSW4wc2V5SjBlWEJsSWpvaVptVmhkSFZ5WlVsa0lpd2lhV1FpT2lKMmFXUmxiME5oY0hSMWNtbHVaeUo5TEhzaWRIbHdaU0k2SW1abFlYUjFjbVZKWkNJc0ltbGtJam9pY25Wc1pYSk5aV0Z6ZFhKbGJXVnVkRU5oY0hSMWNtbHVaeUo5TEhzaWRIbHdaU0k2SW1abFlYUjFjbVZKWkNJc0ltbGtJam9pYldGeWEyVnlUV1ZoYzNWeVpXMWxiblJEWVhCMGRYSnBibWNpZlN4N0ltbGtJam9pWm5KdmJuUmhiRU5oYldWeVlTSXNJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlmU3g3SW5SNWNHVWlPaUptWldGMGRYSmxTV1FpTENKcFpDSTZJbTExYkhScGNHeGxWMjkxYm1SelVHVnlTVzFoWjJVaWZTeDdJbWxrSWpvaWQyOTFibVJFWlhSbFkzUnBiMjRpTENKMGVYQmxJam9pWm1WaGRIVnlaVWxrSW4wc2V5SnBaQ0k2SW14cGRtVlhiM1Z1WkVSbGRHVmpkR2x2YmlJc0luUjVjR1VpT2lKbVpXRjBkWEpsU1dRaWZTeDdJbWxrSWpvaVltOWtlVkJoY25SUWFXTnJaWElpTENKMGVYQmxJam9pWm1WaGRIVnlaVWxrSW4wc2V5SnBaQ0k2SW14dlkyRnNVM1J2Y21GblpVbHRZV2RsY3lJc0luUjVjR1VpT2lKbVpXRjBkWEpsU1dRaWZTeDdJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlMQ0pwWkNJNklteHZZMkZzVTNSdmNtRm5aVlpwWkdWdmN5SjlYU3dpYldWMFlTSTZleUpwYzNOMVpXUWlPaUl5TURJMExUQTNMVEkxSURFeE9qTTVPakkzSWl3aVpYaHdhWEo1SWpvaU1qQXlOQzB3T0Mwek1TQXhNVG96T1Rvd01DSjlmUT09In0=") // The license for a month.
        
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
                          config: MyWoundGeniusLokalizable(),
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
                                                       config: MyWoundGeniusPresenter(completion: { _ in
                
            }),
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
                                                       config: MyWoundGeniusPresenter(completion: { _ in
                
            }),
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
                                                           config: MyWoundGeniusPresenter(completion: { _ in
                    
                }),
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
                                                           config: MyWoundGeniusPresenter(completion: { _ in
                    
                }),
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
