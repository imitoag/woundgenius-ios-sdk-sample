//
//  WoundGeniusPresenterFacialSurgery.swift
//  Sample
//
//  Created by Peter Kulakov on 02.05.2025.
//  Copyright (c) 2025 by imito AG, Zurich, Switzerland
//

import UIKit
import AVFoundation
import WoundGenius
import os

@available(iOS 14.0, *)
private let logger = Logger(subsystem: "io.imito.woundgenius.sdk", category: "WGEvent")

final class WoundGeniusPresenterFacialSurgery: MyWoundGeniusLokalizable, WGPresenterProtocol {
    var rulerScaleAutoDetectionEnabled: Bool = false
    
    var isFacialSurgeryEnabled: Bool {
        return UserDefaults.standard.bool(forKey: SettingKey.isFacialSurgeryEnabled.rawValue)
    }

    var isSingleAreaModeEnabled: Bool {
        return UserDefaults.standard.bool(forKey: SettingKey.isSingleAreaModeEnabled.rawValue)
    }
    
    // MARK: - Public Properties

    var isEmergencyModeEnabled = false
    var userId: String? = "FasilUser5"
    var showMarkerMeasurementTutorialAutomatically = false
    var backNavigationBarButtonTitle: String?
    var isRightNavBarButtonAvailable = true
    var tutorialsAvailableForModes: [ImitoCameraMode] = []
    var isFullHDVideoEnabled = false
    var isCancelBarButtonItemVisible = true
    var headerTextColorUIUtils: UIColor = .black
    var customBlackColorUIUtils: UIColor = .black
    var customRedColorUIUtils: UIColor = WGConstants.Color.red
    var operatingMode: OperatingMode = .SDK
    var isSendPrintablePDFHidden = true
    var isResultsBottomBarHidden = true
    var isDepthOrHeightInputEnabled = true
    var isVideoWithAudioEnabled = false

    var availableModes: [ImitoCameraMode] {
        [.facialSurgery]
    }

    var defaultMode: ImitoCameraMode {
        .facialSurgery
    }

    var availablePoseModes: [PoseMode]?

    var defaultPoseMode: PoseMode? {
        return .fullFaceFront
    }

    var isBodyPartPickerAvailable: Bool {
        false
    }

    var isAddFromLocalStorageAvailable: Bool {
        UserDefaults.standard.bool(forKey: SettingKey.localStorageMediaEnabled.rawValue)
    }

    var isFrontCameraUsageAllowed: Bool {
        false
    }

    var autoDetectionMode: AutoDetectionMode {
        return .none
    }

    var isLiveWoundDetectionEnabled: Bool {
        return false
    }

    var enabledOutlineTypes: [IMOutlineCluster] {
        [ ]
    }

    var minNumberOfMedia: Int {
        UserDefaults.standard.integer(forKey: SettingKey.minNumberOfMediaInt.rawValue)
    }

    var maxNumberOfMedia: Int {
        UserDefaults.standard.integer(forKey: SettingKey.maxNumberOfMediaInt.rawValue)
    }

    var primaryButtonColor: UIColor {
        switch UserDefaults.standard.integer(forKey: SettingKey.primaryButtonColor.rawValue) {
        case 1: return .systemBlue
        case 2: return .green
        default: return UIColor(red: 226/255, green: 53/255, blue: 42/255, alpha: 1.0)
        }
    }

    var lightBackgroundColor: UIColor {
        switch UserDefaults.standard.integer(forKey: SettingKey.lightBackgroundColor.rawValue) {
        case 1: return .lightGray
        case 2: return .yellow
        default: return .white
        }
    }

    var imBlackColor: UIColor {
        .black
    }

    var completionButtonTitle: WGLokalizableKey {
        .CONTINUE_BUTTON
    }

    var tfLiteExtension: TFLiteExtensionProtocol? {
        return nil
    }

    var refreshLastMediaIconAndRightBarButtonState: (() -> Void)?

    // MARK: - Private Properties

    private var capturedItemsToReturn = [CaptureResult]()
    private var completion: (([CaptureResult]) -> Void)!
    private var selectedBodyParts: [String]?

    // MARK: - Initialization

    init(completion: @escaping ([CaptureResult]) -> Void) {
        super.init()
        self.completion = completion
        availablePoseModes = PoseMode.allCases
    }

    // MARK: - WGPresenterProtocol Methods

    func lastMediaIcon(icon: @escaping (UIImage?) -> Void) {
        guard let lastMedia = capturedItemsToReturn.last else {
            icon(nil)
            return
        }

        switch lastMedia {
        case .video(let video): icon(video.preview)
        case .image(let image): icon(image.image)
        case .photo(let photo): icon(photo.preview)
        case .measurement(let measurement): icon(measurement.image)
        case .mesh3D(let mesh): icon(mesh.preview)
        case .facialSurgery(let facial): icon(facial.preview)
        }
    }

    func captured(sampleBuffer: CMSampleBuffer,
                  previewOrientation: UIInterfaceOrientation,
                  videoOrientation: AVCaptureVideoOrientation,
                  processingResult: @escaping ((MarkerDetectionStatus, [CGPoint]?, CGSize?)) -> Void) {
    }

    func handle(event: WGEvent) {
        switch event {
        case .cancelButtonTapped(let vc):
            if !capturedItemsToReturn.isEmpty {
                UIUtils.showConfirmationAlert(title: L.str("CONFIRM_CANCEL_CAPTURING"), message: nil, confirmButton: L.str("CONFIRM"), cancelButton: L.str("DISMISS_BUTTON")) {
                    self.resetCapturedItems()
                    vc.dismiss(animated: true)
                }
            } else {
                vc.dismiss(animated: true)
            }

        case .rightBarButtonTapped(let vc):
            print("case .rightBarButtonTapped")
            completion?(capturedItemsToReturn)
            vc.dismiss(animated: true) { [weak self] in
                self?.resetCapturedItems()
            }

        case .pickedPhoto(let vc, let result, let markerDetector):
            guard vc.currentMode != .markerMeasurement && vc.currentMode != .rulerMeasurement else {
                assertionFailure("Marker/ruler measurement from picked photo not supported.")
                return
            }

            capturedItemsToReturn.append(.photo(result))
            
            self.refreshLastMediaIconAndRightBarButtonState?()

            if capturedItemsToReturn.count == maxNumberOfMedia {
                completion?(capturedItemsToReturn)
                resetCapturedItems()
            }
        case .pickedFacialSurgery(vc: _, result: let result):
//            capturedItemsToReturn.append(.facialSurgery(result)) //.photo(result))
//
//            if capturedItemsToReturn.count == maxNumberOfMedia {
//                completion?(capturedItemsToReturn)
//                resetCapturedItems()
//            }
            
//            assertionFailure("Marker/ruler measurement from picked photo not supported.")
            return

        case .devLogs, .viewWillAppear, .viewWillDisappear:
            break

        @unknown default:
            if #available(iOS 14.0, *) {
                logger.warning("[WGEvent] Unhandled event received — functionality not implemented in WoundGenius app.")
            } else {
                break
            }
        }
    }

    // MARK: - Private Methods

    private func resetCapturedItems() {
        capturedItemsToReturn.removeAll()
        availablePoseModes = PoseMode.allCases
    }

    func removeMedia(at index: Int, completion: @escaping (String?) -> Void) {
        completion(nil)
    }
}
