//
//  String+MattLangan.swift
//  MattLangan
//
//  Created by John M McIntosh on 2016-05-01.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

import Foundation

extension String {
    
    //emoticons which are alphanumeric strings, no longer than 15 characters, contained in parenthesis.
    //https://www.hipchat.com/emoticons  examples do not use numbers!
    
    func getEmoticons() -> [String]? {
        let emoticonsDetector = try? NSRegularExpression(pattern: "\\((\\w{1,15})\\)", options: NSRegularExpressionOptions.CaseInsensitive)
        let results = emoticonsDetector?.matchesInString(self, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, self.utf16.count)).map { $0 }
        
        return results?.map({
            (self as NSString).substringWithRange($0.rangeAtIndex(1))
        })
    }
    
    func getEmoticonsOrNil() -> [String]? {
        let results = self.getEmoticons()
        if results == nil || results?.isEmpty == true {
            return nil
        }
        return results
    }
    
    func getUniqueEmoticonsOrNil() -> [String]? {
        guard let results = self.getEmoticonsOrNil() else {
            return nil
        }
        return Array(Set(results))
    }
    
    /* The vendor code getMentions returns nil (maybe) or an empty string array. This is a hassle, so supply a method that returns nil if nil or empty */
    
    func getMentionsOrNil() -> [String]? {
        let results = self.getMentions()
        if results == nil || results?.isEmpty == true {
            return nil
        }
        return results
    }
    
    func getUniqueMentionsOrNil() -> [String]? {
        guard let results = self.getMentionsOrNil() else {
            return nil
        }
        return Array(Set(results))
    }
    
    func getURLsOrNil() -> [NSURL]? {
        let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue)
        
        let links = detector?.matchesInString(self, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, length)).map {$0 }
        
        //TODO: This is the original code but could be rewrite this as a flatMap
        
        let resolvedLinks = links?.filter { link in
            return link.URL != nil
            }.map { link -> NSURL in
                return link.URL!
        }
        
        if resolvedLinks!.count > 0 {
            return resolvedLinks
        }
        return nil
    }
    
    func getUniqueURLsOrNil() -> [NSURL]? {
        guard let results = self.getURLsOrNil() else {
            return nil
        }
        return Array(Set(results))
    }
}