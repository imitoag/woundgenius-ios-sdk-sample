//
//  L.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.12.2022.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit

class L: NSObject {
    static func str(_ key: String) -> String
    {
        return NSLocalizedString(key, comment: "")
    }
    
    /**
     Replace the inserted substrings like {$COMMON_CSS$} with another key if it is available.
     */
    static func strWithPatterns(_ key: String) -> String {
        var originalString = NSLocalizedString(key, comment: "")
        guard originalString != key else { return originalString }
            
        do {
            let regex = try NSRegularExpression(pattern: "\\{\\$[a-zA-Z0-9_]+\\$\\}")
            
            let occurrancesFirst = regex.matches(in: originalString, range: NSRange(location: 0, length: originalString.count))
                        
            guard !occurrancesFirst.isEmpty else {
                return originalString
            }
            
            for i in 0..<occurrancesFirst.count {
                if i == 0 {
                    let startIndex = String.Index(utf16Offset: occurrancesFirst.first!.range.location,
                                                  in: originalString)
                    let endIndex = String.Index(utf16Offset: occurrancesFirst.first!.range.location + occurrancesFirst.first!.range.length, in: originalString)
                    let substring = originalString[startIndex..<endIndex]
                    let substringKey = substring.replacingOccurrences(of: "{$", with: "").replacingOccurrences(of: "$}", with: "")
                    let lokalized = L.str(substringKey)
                    guard lokalized != substringKey else { return originalString }
                    
                    originalString.replaceSubrange(startIndex..<endIndex, with: lokalized)
                } else {
                    let occurrancesNew = regex.matches(in: originalString, range: NSRange(location: 0, length: originalString.count))
                    if let firstItem = occurrancesNew.first {
                        let startIndex = String.Index(utf16Offset: firstItem.range.location,
                                                      in: originalString)
                        let endIndex = String.Index(utf16Offset: firstItem.range.location + firstItem.range.length, in: originalString)
                        let substring = originalString[startIndex..<endIndex]
                        let substringKey = substring.replacingOccurrences(of: "{$", with: "").replacingOccurrences(of: "$}", with: "")
                        let lokalized = L.str(substringKey)
                        guard lokalized != substringKey else { return originalString }
                        
                        originalString.replaceSubrange(startIndex..<endIndex, with: lokalized)
                    }
                }
            }
            
            return originalString
        } catch {
            return originalString
        }
    }
}
