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
        WG.activate(licenseKey: "eyJhbGciOiIxIiwic2lnIjoiT2ZodnRzQ1lKcERLSmxabzZVUWR2Nlg3YVlWUnFXM2lPNVRrXC90ek5XQ1d2ekcxcEI4eW4rK2VqNEVCSmtGMTdFdlY0WTF3UVdOSTFYcmJ2UkYwNDJkQUM1Y3ZzWGwycTlYdkNjYmVcL1o4RFZsaXpZZ1BMRUtLUThYWkd1MnlUT01WbWpSRlpqS0t3ZDdNck13Z3JpZnZqcGx0R2FFa1VOMXdqa1VQUG54d1lpYlE2OVNJR2E5RjFHV1FaZVwvVDQ0cWUrVWhBRmZ4U1VETndkcHg1VVNlSnRxaVFkc2tKN0ZNRHk3UTNFT2hJbVwvNk1cL2NSRnJZYklLQUpsYUVXYXlTb1d1NmkxRmw3akszTTRxdzFQbTRSUGhUdHVlZDlqWHFEbmNrell4b0JZNWRZYjRmYXRuc1VcL25XczhMcUFFcDU5aUFGaUlGRmVkVUV6b2FpQXNWdTM5RjhjZ3d4RVphblZaT1ZxRW55QjM1aWUyOHAxa29qNmJlUXhLMUlUNlFXcG56aG1Fdlc3MFA5cXV6aElVbUVETDlZN3hjQVp5elFhR1o5N0V5NGVYZDVBUlp4VDN2U2RVcDJWUXNOczNsZ0VYWGFySmJZSW1zVHM1eXlYUXppSzZpWStORmlQd0dLdzJ5UmtYYWM2TDZ4ZE9LVUpHQVBHVUxtZGZEXC81bkszU0NXYlF6alVqcmViQTNZcUl6UzRNMTlGeGRMXC9nVXNUWnhkcFAzejBUQTh0QXlOMEVFU2FcL2gwTjNsQUI1SldGZm5XMUNXYjNnQUorYUpKZnQ1VHphWFVuVFArVlVUOXB2dXlSMjFjajZETUhUSWtLRVRXRkFyXC9tcHBuMWJEWFA1RVJVUXoyalJ4VXpUcVFmRHg1cWVnZzNJTitiWFVIK3d3UVJhcVlVZlNRPSIsImVuYyI6ImV5SmtZWFJoSWpwN2ZTd2lhVzVqYkhWa1pXUWlPbHQ3SW1sa0lqb2lhVzh1YVcxcGRHOHVkMjkxYm1SblpXNXBkWE11YzJGdGNHeGxJaXdpZEhsd1pTSTZJbUZ3Y0d4cFkyRjBhVzl1U1dRaWZTeDdJbWxrSWpvaVUyRnRjR3hsVDJKcVF5SXNJblI1Y0dVaU9pSmpkWE4wYjIxbGNrbGtJbjBzZXlKcFpDSTZJbkJvYjNSdlEyRndkSFZ5YVc1bklpd2lkSGx3WlNJNkltWmxZWFIxY21WSlpDSjlMSHNpYVdRaU9pSjJhV1JsYjBOaGNIUjFjbWx1WnlJc0luUjVjR1VpT2lKbVpXRjBkWEpsU1dRaWZTeDdJbWxrSWpvaWNuVnNaWEpOWldGemRYSmxiV1Z1ZEVOaGNIUjFjbWx1WnlJc0luUjVjR1VpT2lKbVpXRjBkWEpsU1dRaWZTeDdJbWxrSWpvaWJXRnlhMlZ5VFdWaGMzVnlaVzFsYm5SRFlYQjBkWEpwYm1jaUxDSjBlWEJsSWpvaVptVmhkSFZ5WlVsa0luMHNleUpwWkNJNklteHBibVZOWldGemRYSmxiV1Z1ZENJc0luUjVjR1VpT2lKbVpXRjBkWEpsU1dRaWZTeDdJbWxrSWpvaVpuSnZiblJoYkVOaGJXVnlZU0lzSW5SNWNHVWlPaUptWldGMGRYSmxTV1FpZlN4N0ltbGtJam9pWVhKbFlWTmpZVzV1YVc1bk0wUWlMQ0owZVhCbElqb2labVZoZEhWeVpVbGtJbjBzZXlKcFpDSTZJbTExYkhScGNHeGxWMjkxYm1SelVHVnlTVzFoWjJVaUxDSjBlWEJsSWpvaVptVmhkSFZ5WlVsa0luMHNleUpwWkNJNkluZHZkVzVrUkdWMFpXTjBhVzl1SWl3aWRIbHdaU0k2SW1abFlYUjFjbVZKWkNKOUxIc2lhV1FpT2lKc2FYWmxWMjkxYm1SRVpYUmxZM1JwYjI0aUxDSjBlWEJsSWpvaVptVmhkSFZ5WlVsa0luMHNleUpwWkNJNkltSnZaSGxRWVhKMFVHbGphMlZ5SWl3aWRIbHdaU0k2SW1abFlYUjFjbVZKWkNKOUxIc2lhV1FpT2lKc2IyTmhiRk4wYjNKaFoyVkpiV0ZuWlhNaUxDSjBlWEJsSWpvaVptVmhkSFZ5WlVsa0luMHNleUpwWkNJNklteHZZMkZzVTNSdmNtRm5aVlpwWkdWdmN5SXNJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlmU3g3SW1sa0lqb2lZVzVoYkhsMGFXTnpJaXdpZEhsd1pTSTZJbVpsWVhSMWNtVkpaQ0o5WFN3aWJXVjBZU0k2ZXlKcGMzTjFaV1FpT2lJeU1ESTFMVEV5TFRFNElEQTRPalV6T2pRMklpd2laWGh3YVhKNUlqb2lNakF5Tmkwd01TMHpNU0F3T0RvMU16b3dNQ0o5ZlE9PSJ9") // The license for a month.
        
        UINavigationBar.appearance().tintColor = WGConstants.Color.red // This should be configured in AppDelegate by your app.
    }
    
    /// ObjC enums support only Integer enums, thus this feature checking if it is available by the license should be wrapped.
    @objc func isAvailable(feature: String) -> Bool {
        guard let feature = Feature(rawValue: feature) else { return false }
        return WG.isAvailable(feature: feature)
    }
    
    @objc func startCapturing(over: UIViewController) {
        self.router.startCapturing(over: over, completion: { success in
            
        })
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
                return measurementCaptureResult.image.draw(outlines: measurementCaptureResult.outlines)
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
            let outlines = measurement.outlines.enumerated().map {
                MeasuredOutline(id: $0.0, points: $0.1.points,
                                areaInCM: $0.1.areaInCM,
                                circumferenceInCM: $0.1.circumferenceInCM,
                                lengthInCM: $0.1.lengthInCM,
                                lengthStartPointPixels: $0.1.lengthStartPointPixels,
                                lengthEndPointPixels: $0.1.lengthEndPointPixels,
                                widthInCM: $0.1.widthInCM,
                                widthStartPointPixels: $0.1.widthStartPointPixels,
                                widthEndPointPixels: $0.1.widthEndPointPixels,
                                depthCM: $0.1.depthCM,
                                order: $0.1.order,
                                cluster: $0.1.cluster,
                                excluding: $0.1.excluding,
                                parentOutlineOrder: $0.1.parentOutlineOrder,
                                parentOutlineCluster: $0.1.parentOutlineCluster)
            }
            if outlines.filter({ $0.cluster.isSecondaryType }).count > 0 {
                let summary = MeasurementSummaryController(style: tableViewStyle,
                                                           image: measurement.image,
                                                           isRightButtonShown: false,
                                                           outlines: outlines,
                                                           mlOutlines: nil,
                                                           isDepthOrHeightInputEnabled: false,
                                                           config: MyWoundGeniusPresenter(completion: { _ in
                    
                }),
                                                           title: "",
                                                           subtitle: "")
                over.navigationController?.pushViewController(summary, animated: true)
            } else {
                let details = MeasurementDetailsController(style: tableViewStyle,
                                                           image: measurement.image,
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
