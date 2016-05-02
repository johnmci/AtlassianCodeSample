//
//  MLJSONMentions.swift
//  MattLangan
//
//  Created by John M McIntosh on 2016-05-02.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

struct MLJSONMentions: Mappable {
    var mentions: [String]!
    
    init?(_ map: Map) {
        
    }
    
    // Mappable
    mutating func mapping(map: Map) {
        mentions    <- map["mentions"]
    }
    
    init(mentions:[String]) {
        self.mentions = mentions
    }
}