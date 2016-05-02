//
//  MLJSONLinks.swift
//  MattLangan
//
//  Created by John M McIntosh on 2016-05-02.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

struct MLJSONUrls: Mappable {
    var url: String!
    var title: String!
    
    init?(_ map: Map) {
        
    }
    
    // Mappable
    mutating func mapping(map: Map) {
        url    <- map["url"]
        title    <- map["title"]
    }
    
    init(url:String,title:String) {
        self.url = url
        self.title = title
    }
}

struct MLJSONLinks: Mappable {
    var links: [MLJSONUrls]!
    
    init?(_ map: Map) {
        
    }
    
    // Mappable
    mutating func mapping(map: Map) {
        links    <- map["links"]
    }
    
    init(links:[MLJSONUrls]) {
        self.links = links
    }
}