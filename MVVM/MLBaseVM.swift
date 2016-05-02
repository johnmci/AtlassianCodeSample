//
//  MLBaseVM.swift
//  MattLangan
//
//  Created by John M McIntosh on 2016-05-01.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class MLBaseVM {
    var mentions:[String]?
    var emoticons:[String]?
    var urls:[NSURL]?
    var urlTitles = [(urlString:String,titleString:String?)]()  //Could use a Struct here, but let's explore Named Tuples
    var urlTitlesFetched = 0
    var holderForWebKitDelegate = [MLBaseWebViewHolder]()
    
    convenience init(input:String, fetchURLTitlesOnCompletion: ((MLBaseVM) -> Void)? ) {
        self.init()
        mentions = input.getUniqueMentionsOrNil()
        emoticons = input.getUniqueEmoticonsOrNil()
        urls = input.getUniqueURLsOrNil()
        guard let urls = urls, let fetchURLTitlesOnCompletionNotNil = fetchURLTitlesOnCompletion where urls.count > 0 else {
            fetchURLTitlesOnCompletion?(self)
            return
        }

        for i in 0..<urls.count {
            urlTitles.append(("",nil))
            //when we return we have the titlestring and the index value, due to delay these can come back in any order
            //we count these returns and compare to total, because this runs on the main thread we are "thread safe" so the urlTitlesFetched are sane
            
            self.fetchTitleStringFromHost(urls[i].absoluteString, index: i, onCompletion: { (urlString, titleString, targetIndex) in
                self.urlTitles[targetIndex] = (urlString,titleString)
                self.urlTitlesFetched = self.urlTitlesFetched + 1
                if self.urlTitlesFetched == urls.count {
                    fetchURLTitlesOnCompletionNotNil(self)
                }
            })
        }
    }
    
    func rawTextStringForDislay() -> String {
        var returnString = ""
        if let mentions = mentions {
            let jsonMentions = MLJSONMentions(mentions:mentions)
            let jsonString = Mapper().toJSONString(jsonMentions, prettyPrint: true)!
            returnString = returnString + jsonString
        }
        
        if let emoticons = emoticons {
            let jsonMentions = MLJSONEmoticons(emoticons:emoticons)
            let jsonString = Mapper().toJSONString(jsonMentions, prettyPrint: true)!
            returnString = returnString + "\n" + jsonString
        }

        if urls != nil {
            let links = self.urlTitles.map({ (linkTuple) -> MLJSONUrls in
                MLJSONUrls(url: linkTuple.urlString, title: linkTuple.titleString ?? "")
            })
            
            let jsonLinks = MLJSONLinks(links:links)
            let jsonString = Mapper().toJSONString(jsonLinks, prettyPrint: true)!
            returnString = returnString + "\n" + jsonString
        }

        return returnString
    }
    
    //Note this could be private but need to expose for Testing
    
    func fetchTitleStringFromHost(host:String, index: Int, onCompletion: (String,String?,Int) -> Void) {
        let webSiteDelegate = MLBaseWebViewHolder(host: host, index: index, completion: onCompletion)
        
        // We have to hold onto the delegate object here, otherwise it will get Garbaged Collected as the logic runs on a background thread. 
        // This should be GCed when the MLBaseVM is GCed
        
        self.holderForWebKitDelegate.append(webSiteDelegate)
    }
 
    //This is old logic, we parsed the HTML, but this proved to be a problem because the html is not formatted
    
    private func xfetchTitleStringFromHost(host:String, index: Int, onCompletion: (String,String?,Int) -> Void) {
        var titleString:String?
        Alamofire.request(.GET, host)
            .response { request, response, data, error in
                titleString = self.getTitleString(data,possibleError: error)
                onCompletion(host,titleString,index)
        }
    }
    
    //Not Used. MLBaseWebViewHolder uses WKWebView
    //Nice to have would be a function that understood <title> </title> but for any html keyword that uses this pattern
    //Could also be a webpage render that might return title, but that is very heavyweight for just finding the title, but testing showed the text supplied is not formatted


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
        let titleRange = Range.init(start..<nonNilTitleEndRange.startIndex)
        let titleString = nonNilHtmlString.substringWithRange(titleRange)
        return titleString
    }
}
