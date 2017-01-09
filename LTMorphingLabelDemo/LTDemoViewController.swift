//
//  LTDemoViewController.swift
//  LTMorphingLabelDemo
//
//  Created by Lex on 6/23/14.
//  Copyright (c) 2015 lexrus.com. All rights reserved.
//

import UIKit

class LTDemoViewController : UIViewController, LTMorphingLabelDelegate {
    
    private var i = -1
    private var textArray = [
        "What is design?",
        "Design", "Design is not just", "what it looks like", "and feels like.",
        "Design", "is how it works.", "- Steve Jobs",
        "Older people", "sit down and ask,", "'What is it?'",
        "but the boy asks,", "'What can I do with it?'.", "- Steve Jobs",
        "", "Swift", "Objective-C", "iPhone", "iPad", "Mac Mini",
        "MacBook Pro🔥", "Mac Pro⚡️",
        "爱老婆",
        "老婆和女儿"
    ]
    private var text: String {
        i = i >= textArray.count - 1 ? 0 : i + 1
        return textArray[i]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.delegate = self
        
        label.text = "2929"
    }
    
    var previousText: String = ""
    var currentText: String = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLabelWithNumber(Int(arc4random_uniform(4000000)))
    }
    
    func updateLabelWithNumber(number: Int) {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        
        self.label.updateLabel(formatter.stringFromNumber(NSNumber(integer: number)) ?? "")
    }
    
    @IBOutlet private var label: LTMorphingLabel!
    
    @IBAction func changeText(sender: AnyObject) {
        updateLabelWithNumber(Int(arc4random_uniform(4000000)))
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        let seg = sender
        if let effect = LTMorphingEffect(rawValue: seg.selectedSegmentIndex) {
            label.morphingEffect = effect
            changeText(sender)
        }
    }
    
    @IBAction func toggleLight(sender: UISegmentedControl) {
        let isNight = Bool(sender.selectedSegmentIndex == 0)
        view.backgroundColor = isNight ? UIColor.blackColor() : UIColor.whiteColor()
        label.textColor = isNight ? UIColor.whiteColor() : UIColor.blackColor()
        
        updateLabelWithNumber(Int(arc4random_uniform(4000000)))
    }
    
    @IBAction func changeFontSize(sender: UISlider) {
        label.font = UIFont.init(name: label.font.fontName, size: CGFloat(sender.value))
        label.text = label.text
    }
    
}

extension LTDemoViewController {
    
    func morphingDidStart(label: LTMorphingLabel) {
        
    }
    
    func morphingDidComplete(label: LTMorphingLabel) {
        
    }
    
    func morphingOnProgress(label: LTMorphingLabel, progress: Float) {
        
    }
    
}





