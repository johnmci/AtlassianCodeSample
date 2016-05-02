//
//  ViewController.swift
//  MattLangan
//
//  Created by John M McIntosh on 2016-05-01.
//  Copyright © 2016 Corporate Smalltalk Consulting Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    var disposeBag = DisposeBag()

    @IBOutlet weak var enterTextBelow: UILabel!
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var tapHereForUrlTitles: UIButton!
    @IBOutlet weak var outputAreaForResults: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGetURLTitlesTap()
        setupDynamicTextInput()
    }
    
    private func setupGetURLTitlesTap() {
        tapHereForUrlTitles.rx_tap.subscribeNext { [weak self] () in
            guard let strongSelf = self else {
                return
            }
            let _ = MLBaseVM(input: strongSelf.textInput.text, fetchURLTitlesOnCompletion: { (thisMvvm) in
                strongSelf.outputAreaForResults.text = thisMvvm.rawTextStringForDislay()
            })
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupDynamicTextInput() {
        let _ = textInput.rx_text
            .distinctUntilChanged()
            .subscribeNext { [weak self] (inputString) in
                guard let strongSelf = self else {
                    return
                }
                let mvvm = MLBaseVM(input: inputString, fetchURLTitlesOnCompletion: nil)
                strongSelf.outputAreaForResults.text = mvvm.rawTextStringForDislay()
        }
    }
}

