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
 However it is not a Pod (etc) so maintence is an issue. Also he seemed have ignored some warnings ("lazy programmer")
 
 Generally I'd look for something that is limited in scope, seems well liked, clean code, few complaints, and active updating, and as pod etc
 But that task could take a few hours. Obviously I could have just grabbed some code snippets, but want to show where they came from
 
 Other thoughts  Yacc  (yet another compiler complier) and build a parser to extract the three types, but that seems a bit heavyweight 
 
 The MLBaseVM uses Unique to get mentions, urls, Emoticons. However in doing this we lose the order of occurance in the string as it converts to Set then to Array
 */
 
import XCTest
import Alamofire

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
        XCTAssertNil("@(john)".getUniqueMentionsOrNil())
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
        XCTAssertEqual("(awthanks) (awthanks)".getUniqueEmoticonsOrNil()![0],"awthanks")
        XCTAssertNil("(a".getUniqueEmoticonsOrNil())

        //check length cutoff at 15
        XCTAssertNotNil("(123456789012345)".getEmoticonsOrNil())
        XCTAssertNil("(1234567890123456)".getEmoticonsOrNil())
    }
    
    func testGetURls() {
        //check valid values mind Apple is doing this heavy lifting so nothing we can fix 
        
        XCTAssertNotNil("(http://www.example.com)".getURLsOrNil())
        
        //confirm http & https (of course)
        XCTAssertEqual("http://www.example.com".getURLsOrNil()![0].absoluteString,"http://www.example.com")
        XCTAssertEqual("https://www.example.com".getURLsOrNil()![0].absoluteString,"https://www.example.com")
        
        //check for multiple and unquieness
        XCTAssertEqual("https://www.example.com http://www.apple.com".getURLsOrNil()![0].absoluteString,"https://www.example.com")
        XCTAssertEqual("https://www.example.com http://www.apple.com".getURLsOrNil()![1].absoluteString,"http://www.apple.com")
        XCTAssertEqual("https://www.example.com https://www.example.com".getURLsOrNil()!.count,2)
        XCTAssertEqual("https://www.example.com https://www.example.com".getUniqueURLsOrNil()!.count,1)
        XCTAssertEqual("https://www.example.com https://www.example.com".getUniqueURLsOrNil()![0].absoluteString,"https://www.example.com")
        
        //Apple does respect multi-lingual addresses
        
        //http://www.w3.org/International/articles/idn-and-iri/
        //http://JP納豆.例.jp/引き割り/おいしい.html
        XCTAssertNotNil("http://JP納豆.例.jp/引き割り/おいしい.html".getURLsOrNil())
        XCTAssertEqual("http://JP納豆.例.jp/引き割り/おいしい.html".getURLsOrNil()![0].absoluteString,"http://xn--jp-cd2fp15c.xn--fsq.jp/%E5%BC%95%E3%81%8D%E5%89%B2%E3%82%8A/%E3%81%8A%E3%81%84%E3%81%97%E3%81%84.html")
    }

    //Basic checks here for sanity
    func testGetMentionFromMLBaseVM() {
        let mvvm = MLBaseVM(input:"@john",fetchURLTitlesOnCompletion: nil)
        XCTAssertEqual(mvvm.mentions![0],"john")
    }
    
    func testGetUniqueMentionFromMLBaseVM() {
        let mvvm2 = MLBaseVM(input:"@john @harry",fetchURLTitlesOnCompletion: nil)
        let sortedByName = mvvm2.mentions!.sort(<)
        
        XCTAssertEqual(sortedByName[0],"harry")
        XCTAssertEqual(sortedByName[1],"john")
        
        let mvvmOne = MLBaseVM(input:"@john @john",fetchURLTitlesOnCompletion: nil)
        XCTAssertEqual(mvvmOne.mentions!.count,1)
    }

    
    func testGetEmoticonsFromMLBaseVM() {
        let mvvm = MLBaseVM(input:"(awthanks)",fetchURLTitlesOnCompletion: nil)
        XCTAssertEqual(mvvm.emoticons![0],"awthanks")
    }

    func testGetUniqueEmoticonsFromMLBaseVM() {
        let mvvm2 = MLBaseVM(input:"(awthanks)(x)",fetchURLTitlesOnCompletion: nil)
        let sortedByName = mvvm2.emoticons!.sort(<)
        
        XCTAssertEqual(sortedByName[0],"awthanks")
        XCTAssertEqual(sortedByName[1],"x")
        
        let mvvmOne = MLBaseVM(input:"(awthanks)(awthanks)",fetchURLTitlesOnCompletion: nil)
        XCTAssertEqual(mvvmOne.emoticons!.count,1)
    }
    
    func testGetUrlsFromMLBaseVM() {
        let mvvm = MLBaseVM(input:"https://www.example.com",fetchURLTitlesOnCompletion: nil)
        XCTAssertEqual(mvvm.urls![0].absoluteString,"https://www.example.com")
    }
    
    func testGetUniqueUrlsFromMLBaseVM() {
        let mvvm2 = MLBaseVM(input:"https://www.example.com https://www.atlassian.com ",fetchURLTitlesOnCompletion: nil)
        let sortedByName = mvvm2.urls!.sort() {return $0.absoluteString < $1.absoluteString}
        
        XCTAssertEqual(sortedByName[0].absoluteString,"https://www.atlassian.com")
        XCTAssertEqual(sortedByName[1].absoluteString,"https://www.example.com")
        
        let mvvmOne = MLBaseVM(input:"https://www.atlassian.com https://www.atlassian.com",fetchURLTitlesOnCompletion: nil)
        XCTAssertEqual(mvvmOne.urls!.count,1)
    }


    //Ok there are some other tests here like 500, or title string not found in html, but need a server to provide those, could of course use use Mocks for this, but not today
    
    func testGetURLTitleForAtlassian() {
        let titleString = self.fetchTitleStringFromMLBaseVM("https://www.atlassian.com")
        //Shrug we dont' handle the data being nil due to time out or to bad data on host
       XCTAssertEqual(titleString,"Software Development and Collaboration Tools | Atlassia")
    }
    
    func testGetURLTitleForBadURL() {
        let titleString = self.fetchTitleStringFromMLBaseVM("https://www.joesmith.org")
        XCTAssertEqual(titleString,"Status: -1003: A server with the specified hostname could not be found.")
    }
    
    func testGetURLTitleForBadJapanURL() {
        let titleString = self.fetchTitleStringFromMLBaseVM("https://JP納豆.例.jp/引き割り/おいしい.html")
        XCTAssertEqual(titleString,"Status: -1200: An SSL error has occurred and a secure connection to the server cannot be made.")
    }
    
    func fetchTitleStringFromMLBaseVM(host:String) -> String? {
        var titleString:String?
        let theExpectation = self.expectationWithDescription("Get a url")
        
        let mvvm = MLBaseVM(input: host,fetchURLTitlesOnCompletion: nil)
        //Normally we would set the fetchURLTItles to true, but here we need to manually do the fetchTitleStringFromHost so we can wait on theExpectation
        mvvm.fetchTitleStringFromHost(mvvm.urls![0].absoluteString, index: 0) { (aTitleString, index) in
            titleString = aTitleString
            theExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(15.0, handler:nil)
        return titleString
    }
}