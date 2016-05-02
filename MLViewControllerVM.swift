//
//  MLViewControllerVM.swift
//  MattLangan
//
//  Created by John M McIntosh on 2016-05-02.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

import Foundation
import RxSwift

class MLViewControllerVM {
    var inputText = ""
    var outputText = PublishSubject<String>()

    func processTextInputWithNoURLFetch(inputString:String) {
        self.inputText = inputString
        let mvvm = MLParser(input: inputString, fetchURLTitlesOnCompletion: nil)
        outputText.on(.Next(mvvm.rawTextStringForDislay()))
    }
    
    func processTextInputWithURLFetch() {
        let _ = MLParser(input: inputText, fetchURLTitlesOnCompletion: { (thisMvvm) in
            self.outputText.on(.Next(thisMvvm.rawTextStringForDislay()))
        })
    }
}