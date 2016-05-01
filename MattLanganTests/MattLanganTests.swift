//
//  MattLanganTests.swift
//  MattLanganTests
//
//  Created by John M McIntosh on 2016-05-01.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

// Really for doing test drive development.

/*
 The  Swift String Tools github code sample was choosen as it was the first one found that many things we wanted and had an MIT licence
 However it is not a Pod (etc) so maintence is an issue. 
 
 Generally I'd look for something that is limited in scope, seems well liked, clean code, few complaints, and active updating, and as pod etc
 Other thoughts  Yacc  (yet another compiler complier) and build a parser to extract the three types, but that seems a bit heavyweight 
 */
 
import XCTest
@testable import MattLangan
class MattLanganTests: XCTestCase {
    
    func testMentions() {
        
        //Note http://help.hipchat.com/knowledgebase/articles/64429-how-to-mentions-work- is a stale link
        //Maybe https://confluence.atlassian.com/doc/mentions-251725350.html
        
        //Assumption here is a-z,A-Z,0-9  If other language specific characters are used (like Chinese) this obviously won't work
        
        //Check no mentions
        
        XCTAssertNil("".getMentionsOrNil())
        XCTAssertNil(" ".getMentionsOrNil())
        XCTAssertNil("john".getMentionsOrNil())
        
        //Check for @ but no valid mention
        
        XCTAssertNil("@".getMentionsOrNil())
        XCTAssertNil("@@".getMentionsOrNil())
        XCTAssertNil("@ @".getMentionsOrNil())
        XCTAssertNil("@$".getMentionsOrNil())
        //We might type this but it's illegal
        XCTAssertNil("@(john) ".getMentionsOrNil())
        
        //Check for valid data
        XCTAssertNotNil("@john".getMentionsOrNil())
        XCTAssertEqual("@john".getMentionsOrNil()![0],"john")
        XCTAssertEqual("@john ".getMentionsOrNil()![0],"john")
        //In this case % is the terminator versus a space
        XCTAssertEqual("@john% ".getMentionsOrNil()![0],"john")
        
        //Although it talks about words, I'm guessing john2 would be legal
        XCTAssertNotNil("@john2".getMentionsOrNil())
        XCTAssertEqual("@John2 ".getMentionsOrNil()![0],"John2")

        //Check for two
        XCTAssertEqual("@john @harry ".getMentionsOrNil()![0],"john")
        XCTAssertEqual("@john @harry ".getMentionsOrNil()![1],"harry")
        XCTAssertEqual("@john @john ".getMentionsOrNil()![0],"john")
        XCTAssertEqual("@john @john ".getMentionsOrNil()![1],"john")
        
        //Check for Unique
        XCTAssertEqual("@john @harry ".getUniqueMentionsOrNil()!.count,2)
        XCTAssertEqual("@john @john ".getUniqueMentionsOrNil()!.count,1)
        
    }
    
    func testEmoticons() {

        //Assumption here is a-z,A-Z,0-9  If other language specific characters are used (like Chinese) this obviously won't work
        //check invalid constructs
        
        XCTAssertNil("()".getEmoticonsOrNil())
        XCTAssertNil("(a )".getEmoticonsOrNil())
        XCTAssertNil("(a ".getEmoticonsOrNil())
        XCTAssertNil("(a".getEmoticonsOrNil())
        XCTAssertNil("(http://www.example.com)".getEmoticonsOrNil())
        
        //check legal constructs
        XCTAssertNotNil("((a))".getEmoticonsOrNil())
        XCTAssertNotNil("(awthanks)".getEmoticonsOrNil())
        XCTAssertNotNil("(Awthanks123)".getEmoticonsOrNil())
        XCTAssertEqual("(awthanks)".getEmoticonsOrNil()![0],"awthanks")

        //Check for two
        XCTAssertEqual("(awthanks)(x)".getEmoticonsOrNil()![0],"awthanks")
        XCTAssertEqual("(awthanks) (x)".getEmoticonsOrNil()![1],"x")
        XCTAssertEqual("(awthanks) (awthanks) ".getEmoticonsOrNil()![0],"awthanks")
        XCTAssertEqual("(awthanks) (awthanks) ".getEmoticonsOrNil()![1],"awthanks")
        
        //Check for Unique
        XCTAssertEqual("(awthanks) (x)".getUniqueEmoticonsOrNil()!.count,2)
        XCTAssertEqual("(awthanks) (awthanks)".getUniqueEmoticonsOrNil()!.count,1)
        XCTAssertEqual("(awthanks) (awthanks)".getEmoticonsOrNil()![0],"awthanks")

        //check length cutoff at 15
        XCTAssertNotNil("(123456789012345)".getEmoticonsOrNil())
        XCTAssertNil("(1234567890123456)".getEmoticonsOrNil())
    }
    
    func testGetURls() {
        //check valid values
        XCTAssertNotNil("(http://www.example.com)".getURLsOrNil())
        
        //confirm http & https (of course)
        XCTAssertEqual("http://www.example.com".getURLsOrNil()![0].absoluteString,"http://www.example.com")
        XCTAssertEqual("https://www.example.com".getURLsOrNil()![0].absoluteString,"https://www.example.com")
        
        //check for multiple and unquieness
        XCTAssertEqual("https://www.example.com http://www.apple.com".getURLsOrNil()![0].absoluteString,"https://www.example.com")
        XCTAssertEqual("https://www.example.com http://www.apple.com".getURLsOrNil()![1].absoluteString,"http://www.apple.com")
        XCTAssertEqual("https://www.example.com https://www.example.com".getURLsOrNil()!.count,2)
        XCTAssertEqual("https://www.example.com https://www.example.com".getUniqueURLsOrNil()!.count,1)
        
        //Apple does respect multi-lingual addresses
        
        //http://www.w3.org/International/articles/idn-and-iri/
        //http://JP納豆.例.jp/引き割り/おいしい.html
        XCTAssertNotNil("http://JP納豆.例.jp/引き割り/おいしい.html".getURLsOrNil())
        XCTAssertEqual("http://JP納豆.例.jp/引き割り/おいしい.html".getURLsOrNil()![0].absoluteString,"http://xn--jp-cd2fp15c.xn--fsq.jp/%E5%BC%95%E3%81%8D%E5%89%B2%E3%82%8A/%E3%81%8A%E3%81%84%E3%81%97%E3%81%84.html")
    }
}


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
        
        return links?.filter { link in
            return link.URL != nil
            }.map { link -> NSURL in
                return link.URL!
        }
    }
    
    func getUniqueURLsOrNil() -> [NSURL]? {
        guard let results = self.getURLsOrNil() else {
            return nil
        }
        return Array(Set(results))
    }
}
