//
//  MLBaseWebViewHolder.swift
//  MattLangan
//
//  Created by John M McIntosh on 2016-05-02.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

//This was created to handle the headless use of WKWebView to get the title after Safari/webkit has rendered the page. 
//navigationDelegate is weak, so the strong relationship is to webSite, but as mentioned in MLParser we have to hold onto this instance to prevent a GC from happening

import Foundation
import WebKit

class MLBaseWebViewHolder:NSObject, WKNavigationDelegate {
    var host:String!
    var onCompletion:((String,String?) -> Void)?
    var webSite = WKWebView()
    
    convenience init(host:String, completion:(String,String?) -> Void) {
        self.init()
        self.host = host
        self.onCompletion = completion
        self.webSite.navigationDelegate = self
        let url = NSURL(string:host)!
        let req = NSURLRequest(URL:url)
        self.webSite.loadRequest(req)
    }
    
    /*! @abstract Decides whether to allow or cancel a navigation.
     @param webView The web view invoking the delegate method.
     @param navigationAction Descriptive information about the action
     triggering the navigation request.
     @param decisionHandler The decision handler to call to allow or cancel the
     navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
     @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
     */
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.Allow)
    }
    
    /*! @abstract Decides whether to allow or cancel a navigation after its
     response is known.
     @param webView The web view invoking the delegate method.
     @param navigationResponse Descriptive information about the navigation
     response.
     @param decisionHandler The decision handler to call to allow or cancel the
     navigation. The argument is one of the constants of the enumerated type WKNavigationResponsePolicy.
     @discussion If you do not implement this method, the web view will allow the response, if the web view can show it.
     */
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.Allow)
    }
    
    /*! @abstract Invoked when an error occurs while starting to load data for
     the main frame.
     @param webView The web view invoking the delegate method.
     @param navigation The navigation.
     @param error The error that occurred.
     */
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        onCompletion!(self.host,"Status: \(error.code): \(error.localizedDescription)")
    }
    
    /*! @abstract Invoked when a main frame navigation completes.
     @param webView The web view invoking the delegate method.
     @param navigation The navigation.
     */
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        //TODO: we are returning the final redirected URL here, is that correct?
        onCompletion!((webView.URL?.absoluteString)!,webView.title)
    }
    
    /*! @abstract Invoked when an error occurs during a committed main frame
     navigation.
     @param webView The web view invoking the delegate method.
     @param navigation The navigation.
     @param error The error that occurred.
     */
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        onCompletion!(self.host,"Status: \(error.code): \(error.localizedDescription)")
    }
}
