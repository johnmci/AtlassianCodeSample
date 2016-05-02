//
//  ViewController.swift  //boring default name, maybe change
//  MattLangan
//
//  Created by John M McIntosh on 2016-05-01.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    var model = MLViewControllerVM()
    var disposeBag = DisposeBag()
    var backgroundWorkScheduler:OperationQueueScheduler!
    
    @IBOutlet weak var enterTextBelow: UILabel!
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var tapHereForUrlTitles: UIButton!
    @IBOutlet weak var outputAreaForResults: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScheduler()
        setupGetURLTitlesTap()
        setupDynamicTextInput()
        setupTextOutput()
        //TODO: Setup logic to disable tap URL button until there are URLS provided (Exercise for the reader)
     }
    
    private func setupScheduler() {
        let operationQueue = NSOperationQueue()
        operationQueue.name = "ML background parser"
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = NSQualityOfService.UserInitiated
        self.backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    }
    
    private func setupGetURLTitlesTap() {
        tapHereForUrlTitles.rx_tap.subscribeNext { [weak self] () in
            //could do guard, but simple statement like this works
            self?.model.processTextInputWithURLFetch()
        }
            .addDisposableTo(disposeBag)
    }
    
    private func setupDynamicTextInput() {
        let _ = textInput.rx_text
            .distinctUntilChanged()
            .observeOn(self.backgroundWorkScheduler)
            .subscribeNext { [weak self] (inputString) in
                self?.model.processTextInputWithNoURLFetch(inputString)
        }
        textInput.becomeFirstResponder()
    }
    
    private func setupTextOutput() {
        bindSourceToTextView(model.outputText, label: outputAreaForResults)
    }
    
    private func bindSourceToTextView(source: PublishSubject<String>, label: UITextView) {
        source
            .observeOn(MainScheduler.instance)
            .subscribeNext { text in
                label.text = text
            }
            .addDisposableTo(disposeBag)
    }
}
