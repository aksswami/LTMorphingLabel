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
    
    func updateLabel(newText: String) {
        self.previousText = self.currentText
        self.currentText = newText
        
        var sequencedNumber = String.sequenceStringForOdometer(self.previousText, endString: self.currentText)
        var sequenceCount = sequencedNumber.count
        print("from:: \(self.previousText) :: to:: \(self.currentText)")
        
        if #available(iOS 10.0, *) {
            NSTimer.scheduledTimerWithTimeInterval(0.1, repeats: true, block: { (timer) in
                sequenceCount -= 1
                let numberString = sequencedNumber[sequenceCount]
                self.label.text = numberString
                print(numberString)
                if sequenceCount == 0 {
                    timer.invalidate()
                }
            })
        } else {
            // Fallback on earlier versions
        }

    }
    
    func updateLabelWithNumber(number: Int) {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        
        updateLabel(formatter.stringFromNumber(NSNumber(integer: number)) ?? "")
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


extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
    
    static func sequenceStringForOdometer(startString: String, endString: String) -> [String] {
        var sequenceMatrix = [[String]]()
        
        let diff = startString.diffWith(endString)
        for i in (0..<diff.0.count) {
            sequenceMatrix.append([String]())
            if i >= endString.characters.count {
                sequenceMatrix[i].append("")
                continue
            }
            switch diff.0[i] {
            case .Replace:
                var past: Int?
                var new: Int?
                if i < startString.characters.count {
                    past = Int(startString[i])
                }
                new = Int(endString[i])
                if let new = new, past = past {
                    if past < new {
                        sequenceMatrix[i].appendContentsOf((past...new).map {"\($0)"})
                    } else {
                        sequenceMatrix[i].appendContentsOf((new...past).reverse().map {"\($0)"})
                    }
                } else {
                    sequenceMatrix[i].append(endString[i])
                }
                break
            case .Delete:
                sequenceMatrix[i].append("")
                break
            case .Add:
                sequenceMatrix[i].append(endString[i])
                break
            case .Same:
                sequenceMatrix[i].append(endString[i])
                break
            default:
                sequenceMatrix[i].append("")
                break
            }
        }
        print(sequenceMatrix)
        var max = 0
        for i in sequenceMatrix {
            if i.count > max {
                max = i.count
            }
        }
        for i in 0..<sequenceMatrix.count {
            let rowCount = sequenceMatrix[i].count
            if rowCount < max {
                let lastElement = sequenceMatrix[i].last ?? ""
                let tempSequence = (1...(max-rowCount)).map { _ in return lastElement}
                sequenceMatrix[i].appendContentsOf(tempSequence)
            }
        }
        let transStr = Array<String>.transpose(sequenceMatrix)
        var sequencedStrings = [String]()
        for text in transStr {
            sequencedStrings.append(text.reduce("", combine: +))
        }
        sequencedStrings = sequencedStrings.reverse()
        
        return sequencedStrings
    }
}

extension Array {
    public static func transpose<T>(input: [[T]]) -> [[T]] {
        if input.isEmpty { return [[T]]() }
        let count = input[0].count
        var out = [[T]](count: count, repeatedValue: [T]())
        for outer in input {
            for (index, inner) in outer.enumerate() {
                out[index].append(inner)
            }
        }
        
        return out
    }
    
}
