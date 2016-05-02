//
//  MLBaseVM.swift
//  MattLangan
//
//  Created by John M McIntosh on 2016-05-01.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

import Foundation
import Alamofire

class MLBaseVM {
    var mentions:[String]?
    var emoticons:[String]?
    var urls:[NSURL]?
    var urlTitles:[String?]?
    var titleDone = false
    
    convenience init(input:String, fetchURLTitles: Bool) {
        self.init()
        mentions = input.getUniqueMentionsOrNil()
        emoticons = input.getUniqueEmoticonsOrNil()
        urls = input.getUniqueURLsOrNil()
        urlTitles = [String?](count: urls!.count, repeatedValue: nil)
        if urls == nil || !fetchURLTitles {
            return
        }

        for i in 0..<urls!.count {
            self.fetchTitleStringFromHost(urls![i].absoluteString, index: i, onCompletion: { (titleString, targetIndex) in
                self.urlTitles![targetIndex] = titleString
                self.titleDone = i == (self.urls!.count-1)
            })
        }
    }
    
    //Note this could be private but need to expose for Testing
    func fetchTitleStringFromHost(host:String, index: Int, onCompletion: (String?,Int) -> Void) {
        var titleString:String?
        Alamofire.request(.GET, host.getURLsOrNil()![0].absoluteString)
            .response { request, response, data, error in
                titleString = self.getTitleString(data,possibleError: error)
                onCompletion(titleString,index)
        }
    }
    
    private func getTitleString(data:NSData?,possibleError:NSError?) -> String? {
        if let actualError = possibleError {
            return "Status: \(actualError.code): \(actualError.localizedDescription)"
        }
        
        guard let nonNilData = data,let nonNilHtmlString = String(data: nonNilData, encoding: NSUTF8StringEncoding) else {
            return nil
        }
        let titleMarker = "<title>"
        guard let nonNilTitleRange = nonNilHtmlString.rangeOfString(titleMarker, options: .CaseInsensitiveSearch, range: nil, locale: nil),
            //Ensure we search after the <title>
            let nonNilTitleEndRange = nonNilHtmlString.rangeOfString("</title>", options: .CaseInsensitiveSearch, range: Range(nonNilTitleRange.startIndex.advancedBy(titleMarker.length)..<nonNilHtmlString.endIndex), locale: nil) else {
                return nil
        }
        let start = nonNilTitleRange.startIndex.advancedBy(titleMarker.length) //Ok it's a duplication statement collides with the guard clause usage
        let titleRange = Range.init(start..<nonNilTitleEndRange.startIndex.advancedBy(-1))
        let titleString = nonNilHtmlString.substringWithRange(titleRange)
        return titleString
    }
}

