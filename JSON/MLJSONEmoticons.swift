//
//  MLJSONEmoticons.swift
//  MattLangan
//
//  Created by John M McIntosh on 2016-05-02.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

struct MLJSONEmoticons: Mappable {
    var emoticons: [String]!
    
    init?(_ map: Map) {
        
    }
    
    // Mappable
    mutating func mapping(map: Map) {
        emoticons    <- map["emoticons"]
    }
    
    init(emoticons:[String]) {
        self.emoticons = emoticons
    }
}