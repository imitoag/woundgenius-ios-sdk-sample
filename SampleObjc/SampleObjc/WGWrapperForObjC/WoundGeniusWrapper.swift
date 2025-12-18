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
        WG.activate(licenseKey: "eyJzaWciOiJGY2dwd25kaVU0d3I4VGlERVNLVW1maHBUMlVxWTluMEg5VUdCT29YWDlURzJJZ3hCaUxLSnFcL3FrVGxnajYxaWtvd0Q3R3A2THlIemFEKys0VFBiYzJBbWVYYkFUcElrTEZEZ3UxOE1hWHhpXC9KN3c2d2lDZ0l1clh1U0FEbGR2SHJpRXZ2QVJzS3JHXC90TVArdW9qYkhmcDd6T0tsa1NvZHR1d3g4RDRcL0taSE5SdjlyY08xQVRkRlRXaElhMDRQeWYyQm5hOVwvZEZPWmREVzZ0VU5HV1U4MlBsSHFkWlgyMzNqdktJSG8rc1RmdEMxd29MeU5Lb3lvbldYNVwvbEppUXNBWUpveVNheWc3blRSNUdjQmdEM280M0FPRDZIVDY1R04zOThGeTVXeituYkc0SlZ4bXNIVmlLY0tSb0QyTjRCTGhtanAxbDdRaFE2cG45dm14OEJMNTYzS2VVdlJPTmRHSm1tYXdLUkNOOThvTzRIRUl1cWU1U1dKaGdsemZNOE5YbStUKzVIbmhQWGtkXC9ZYThZV0hCclh1T0sxbUpZNXFHcFZcLzRjTm9ISDdnZitlakRmajNEenlaVUpyM2Y1Q2h1RklNSzdVNWd0bFFSTDlROER1WG5NUEs4RnlTY3I0cFZGOWI2REZmMU1lMTZzVjhtckhRNTIydVJYM2tRTWpIRWIzd2FBUmg0aUJVTjROb0xYK0t1WXlWNTBwWG55eElsK3JpdGNKeFRcL3Q2TXZYdW9GK1wvWFA3bkNJNjZuS21ZWVhmSUdSVDF5bDI3b1NqOEdTanJ4a2FBb0dKVFwvaGdOdjJXTDBvb0t1K0tzdTBCT01IZFBIb1NVYjFQZVwvdjhLZjVFYzM3N21PemZqSlR2WExkNE1OYVRVQjdZUVE0QTYrT1RTS3ZSMD0iLCJhbGciOiIxIiwiZW5jIjoiZXlKa1lYUmhJanA3ZlN3aWJXVjBZU0k2ZXlKcGMzTjFaV1FpT2lJeU1ESTBMVEV3TFRBeklEQTNPakF5T2pRNUlpd2laWGh3YVhKNUlqb2lNakF5TlMweE1DMHdNeUF3Tnpvd01qb3dNQ0o5TENKcGJtTnNkV1JsWkNJNlczc2lhV1FpT2lKcGJ5NXBiV2wwYnk1M2IzVnVaR2RsYm1sMWN5NXpZVzF3YkdVaUxDSjBlWEJsSWpvaVlYQndiR2xqWVhScGIyNUpaQ0o5TEhzaWFXUWlPaUp3YUc5MGIwTmhjSFIxY21sdVp5SXNJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlmU3g3SW5SNWNHVWlPaUptWldGMGRYSmxTV1FpTENKcFpDSTZJblpwWkdWdlEyRndkSFZ5YVc1bkluMHNleUowZVhCbElqb2labVZoZEhWeVpVbGtJaXdpYVdRaU9pSnlkV3hsY2sxbFlYTjFjbVZ0Wlc1MFEyRndkSFZ5YVc1bkluMHNleUowZVhCbElqb2labVZoZEhWeVpVbGtJaXdpYVdRaU9pSnRZWEpyWlhKTlpXRnpkWEpsYldWdWRFTmhjSFIxY21sdVp5SjlMSHNpZEhsd1pTSTZJbVpsWVhSMWNtVkpaQ0lzSW1sa0lqb2labkp2Ym5SaGJFTmhiV1Z5WVNKOUxIc2lkSGx3WlNJNkltWmxZWFIxY21WSlpDSXNJbWxrSWpvaWJYVnNkR2x3YkdWWGIzVnVaSE5RWlhKSmJXRm5aU0o5TEhzaWFXUWlPaUozYjNWdVpFUmxkR1ZqZEdsdmJpSXNJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlmU3g3SW5SNWNHVWlPaUptWldGMGRYSmxTV1FpTENKcFpDSTZJbXhwZG1WWGIzVnVaRVJsZEdWamRHbHZiaUo5TEhzaWFXUWlPaUppYjJSNVVHRnlkRkJwWTJ0bGNpSXNJblI1Y0dVaU9pSm1aV0YwZFhKbFNXUWlmU3g3SW5SNWNHVWlPaUptWldGMGRYSmxTV1FpTENKcFpDSTZJbXh2WTJGc1UzUnZjbUZuWlVsdFlXZGxjeUo5TEhzaWRIbHdaU0k2SW1abFlYUjFjbVZKWkNJc0ltbGtJam9pYkc5allXeFRkRzl5WVdkbFZtbGtaVzl6SW4xZGZRPT0ifQ==") // The license for a month.
        
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
