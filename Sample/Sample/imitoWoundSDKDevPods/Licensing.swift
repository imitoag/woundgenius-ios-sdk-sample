////
////  Licensing.swift
////  Sample
////
////  Created by Eugene Naloiko on 20.07.2023.
////
//
//import UIKit
//import WoundGenius
//
//struct EncData: Codable {
//    
//}
//
//enum Alg: String, Codable {
//    case rsa2048_sha256 = "1"
//}
//
//enum IncludedItemType: String, Codable {
//    case applicationId
//    case customerId
//    case featureId
//}
//
//struct IncludedItem: Codable {
//    let id: String
//    let type: IncludedItemType
//}
//
//struct Meta: Codable {
//    let issued: String
//    let expiry: String
//}
//
//struct Enc: Codable {
//    let data: EncData
//    let included: [IncludedItem]
//    let meta: Meta
//}
//
//struct LicenseContent: Codable {
//    let enc: String
//    let sig: String
//    let alg: Alg
//}
//
//enum Feature: String {
//    case bodyPartPicker
//    case woundDetection
//    case tissueTypeDetection
//    case photoCapturing
//    case videoCapturing
//    case handyscropeCapturing
//    case rulerMeasurementCapturing
//    case markerMeasurementCapturing
//    case manualMeasurementInput
//    case multipleWoundsPerImage
//    case localStorageImages
//    case localStorageVideos
//    case barcodeScanning
//}
//
//enum LicenseStatus {
//    case locked(issue: String?)
//    case unlocked(features: [Feature])
//}
//
//class Licensing: NSObject {
//    static private(set) var shared: Licensing!
//    
//    let value: [UInt8] = [37, 37, 33, 56, 39, 117, 1, 10, 44, 11, 3, 6, 8, 76, 41, 1, 81, 27, 90, 55, 47, 114, 5, 2, 41, 45, 39, 56, 47, 72, 118, 7, 37, 37, 33, 56, 45, 114, 11, 5, 41, 11, 44, 31, 33, 20, 18, 5, 89, 43, 33, 37, 40, 121, 26, 30, 44, 93, 38, 18, 64, 116, 23, 33, 96, 34, 5, 55, 56, 91, 7, 17, 2, 43, 28, 92, 11, 121, 40, 20, 58, 32, 57, 92, 54, 73, 43, 46, 26, 58, 1, 51, 46, 78, 25, 114, 40, 45, 30, 34, 96, 78, 119, 48, 43, 35, 16, 34, 69, 78, 50, 118, 90, 9, 40, 8, 38, 77, 117, 13, 15, 57, 52, 1, 9, 69, 50, 33, 29, 45, 46, 70, 3, 117, 50, 41, 27, 67, 95, 5, 14, 78, 122, 15, 29, 92, 62, 52, 13, 24, 28, 56, 61, 42, 92, 35, 28, 116, 4, 20, 3, 2, 18, 18, 13, 69, 117, 2, 93, 62, 29, 13, 93, 73, 42, 22, 1, 63, 62, 34, 35, 116, 5, 33, 91, 9, 9, 59, 11, 70, 43, 109, 17, 32, 62, 37, 44, 21, 121, 33, 3, 47, 33, 8, 38, 73, 12, 118, 28, 10, 81, 70, 4, 72, 8, 56, 62, 15, 27, 54, 95, 115, 111, 116, 20, 41, 13, 69, 87, 80, 122, 1, 96, 30, 45, 24, 62, 101, 111, 19, 12, 37, 58, 24, 47, 80, 4, 3, 6, 90, 61, 65, 88, 100, 119, 55, 4, 60, 44, 6, 96, 99, 60, 9, 35, 90, 44, 69, 44, 117, 117, 20, 92, 40, 20, 54, 30, 73, 23, 41, 48, 27, 9, 31, 6, 99, 57, 2, 36, 54, 52, 61, 23, 25, 10, 3, 20, 89, 2, 96, 93, 101, 43, 54, 90, 12, 33, 34, 95, 79, 33, 56, 20, 71, 34, 32, 93, 16, 44, 4, 29, 3, 40, 20, 47, 71, 60, 12, 12, 15, 15, 68, 38, 22, 7, 55, 81, 43, 8, 50, 15, 67, 35, 62, 81, 31, 3, 60, 44, 113, 46, 115, 50, 60, 3, 92, 14, 119, 11, 35, 14, 4, 46, 70, 47, 67, 17, 2, 59, 8, 33, 39, 8, 21, 57, 6, 31, 11, 18, 35, 9, 119, 16, 14, 32, 29, 44, 34, 6, 106, 121, 3, 32, 48, 50, 20, 44, 20, 24, 120, 30, 44, 3, 72, 8, 79, 18, 47, 91, 61, 15, 70, 94, 108, 56, 4, 34, 21, 34, 52, 95, 122, 20, 32, 7, 29, 34, 29, 60, 18, 19, 47, 35, 10, 67, 68, 11, 68, 8, 35, 33, 3, 40, 67, 12, 90, 114, 35, 13, 60, 96, 71, 47, 21, 40, 48, 39, 39, 81, 96, 60, 19, 60, 19, 25, 3, 52, 51, 34, 105, 121, 47, 50, 26, 48, 22, 12, 75, 113, 115, 47, 15, 81, 47, 3, 111, 45, 24, 5, 36, 36, 67, 31, 77, 28, 39, 25, 15, 35, 25, 7, 108, 11, 32, 8, 40, 67, 30, 47, 80, 43, 44, 63, 61, 47, 51, 8, 20, 38, 11, 81, 45, 59, 68, 1, 21, 38, 16, 4, 33, 92, 13, 65, 117, 10, 105, 38, 34, 46, 35, 46, 71, 19, 16, 12, 7, 14, 49, 55, 68, 5, 44, 29, 1, 20, 70, 14, 89, 35, 32, 27, 10, 29, 22, 59, 99, 54, 48, 12, 92, 57, 36, 96, 100, 119, 118, 71, 54, 52, 23, 35, 102, 16, 118, 63, 71, 96, 27, 23, 74, 39, 11, 1, 2, 94, 24, 15, 122, 49, 6, 3, 57, 7, 27, 32, 109, 5, 24, 39, 92, 6, 18, 62, 101, 37, 118, 4, 12, 48, 40, 6, 112, 3, 33, 8, 59, 57, 5, 33, 21, 15, 9, 11, 90, 13, 7, 9, 121, 20, 55, 61, 42, 63, 13, 28, 116, 43, 2, 45, 62, 52, 60, 94, 20, 122, 22, 13, 60, 16, 31, 25, 83, 5, 33, 52, 38, 90, 65, 33, 104, 10, 113, 91, 6, 60, 63, 34, 119, 4, 10, 20, 59, 39, 26, 87, 82, 38, 55, 33, 60, 13, 34, 10, 106, 26, 118, 59, 56, 96, 92, 43, 114, 18, 115, 25, 21, 39, 60, 88, 73, 8, 62, 5, 90, 16, 50, 3, 106, 40, 47, 12, 31, 67, 1, 93, 114, 9, 4, 41, 61, 41, 55]
//    
//    public private(set) var status: LicenseStatus = .locked(issue: nil)
//    
//    lazy var dateFormatter: DateFormatter = {
//        let df = DateFormatter()
//        df.locale = Locale(identifier: "en_US_POSIX")
//        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        df.timeZone = TimeZone(secondsFromGMT: 0)
//        return df
//    }()
//    
//    init(license: String) {
//        super.init()
//        self.status = self.verifyLicense(license: license)
//        Licensing.shared = self
//    }
//    
//    private func verifyLicense(license: String) -> LicenseStatus {
//        guard let lincenseData = Data(base64Encoded: license) else {
//            return .locked(issue: "Failed to encode the license key")
//        }
//        
//        do {
//            let licenseContent = try JSONDecoder().decode(LicenseContent.self, from: lincenseData)
//            let signature = try Signature(base64Encoded: licenseContent.sig)
//            let clearMessage = try ClearMessage(string: licenseContent.enc, using: .utf8)
//            let notModifiedPayloadCheck = try clearMessage.verify(with: PublicKey(base64Encoded: Modifier().reveal(key: self.value, salt: "imito AG")), signature: signature, digestType: .sha256)
//            guard notModifiedPayloadCheck else {
//                return .locked(issue: "License key was illegally modified")
//            }
//            
//            guard let encJSONData = Data(base64Encoded: licenseContent.enc) else {
//                return .locked(issue: "Failed to encode the content")
//            }
//            
//            let enc = try JSONDecoder().decode(Enc.self, from: encJSONData)
//            guard let issuedUTC = dateFormatter.date(from: enc.meta.issued), let expiryUTC = dateFormatter.date(from: enc.meta.expiry) else {
//                return .locked(issue: "Corrupted license key metadata (date format).")
//            }
//            let nowTimestamp = Date().timeIntervalSince1970
//            guard nowTimestamp > issuedUTC.timeIntervalSince1970, nowTimestamp < expiryUTC.timeIntervalSince1970 else {
//                return .locked(issue: "WoundGenius license has expired. Please update the app to latest version or contact your IT support.")
//            }
//            
//            let includedAppIds = enc.included.filter({ $0.type == .applicationId })
//            guard includedAppIds.contains(where: { $0.id == Bundle.main.bundleIdentifier }) else {
//                return .locked(issue: "This App Id is locked. The bundle ids allowed by your license are \(includedAppIds.compactMap({ $0.id }).joined(separator: ", "))")
//            }
//            
//            let unlockedFeatures = enc.included
//                .filter({ $0.type == .featureId })
//                .compactMap({ Feature(rawValue: $0.id) })
//            guard unlockedFeatures.count > 0 else {
//                return .locked(issue: "No unlocked features. Please contact imito support.")
//            }
//            
//            return .unlocked(features: unlockedFeatures)
//        } catch {
//            return .locked(issue: "Corrupted License Key")
//        }
//    }
//    
//    func zipPW() -> String {
//        let value = Modifier().reveal(key: self.value, salt: "imito AG")
//        return String(value.prefix(10) + value.suffix(10))
//    }
//}
//
//class Modifier {
//    func bytesByObfuscatingString(string: String, salt: String) -> [UInt8] {
//        let text = [UInt8](string.utf8)
//        let cipher = [UInt8](salt.utf8)
//        let length = cipher.count
//        
//        var encrypted = [UInt8]()
//        
//        for t in text.enumerated() {
//            encrypted.append(t.element ^ cipher[t.offset % length])
//        }
//        
//        let increased = encrypted.map({ $0 + 1 })
//        
//        #if DEVELOPMENT
//        print("Salt used: \(self.salt)\n")
//        print("Swift Code:\n************")
//        print("// Original \"\(string)\"")
//        print("let key: [UInt8] = \(encrypted)\n")
//        #endif
//    
//        return encrypted
//    }
//
//    
//    func reveal(key: [UInt8], salt: String) -> String {
//        let cipher = [UInt8](salt.utf8)
//        let length = cipher.count
//        
//        var decrypted = [UInt8]()
//        
//        for k in key.map({ $0 - 1 }).enumerated() {
//            decrypted.append(k.element ^ cipher[k.offset % length])
//        }
//        
//        return String(bytes: decrypted, encoding: .utf8)!
//    }
//}
//
