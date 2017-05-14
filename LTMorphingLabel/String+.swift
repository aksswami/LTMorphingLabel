//
//  String+.swift
//  LTMorphingLabelDemo
//
//  Created by Amit kumar Swami on 09/01/17.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

import Foundation

extension String {
    
        subscript (i: Int) -> Character {
        return self[self.index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: CountableRange<Int>) -> String? {
        guard let start = self.index(startIndex, offsetBy: r.startIndex, limitedBy: endIndex),
            let end = self.index(start, offsetBy: r.endIndex, limitedBy: endIndex) else {
                return nil
        }
        return self[start..<end]
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
            case .replace:
                var past: Int?
                var new: Int?
                if i < startString.characters.count {
                    past = Int(startString[i])
                }
                new = Int(endString[i])
                if let new = new, let past = past {
                    if past < new {
                        sequenceMatrix[i].append(contentsOf: (past...new).map {"\($0)"})
                    } else {
                        sequenceMatrix[i].append(contentsOf: (new...past).reversed().map {"\($0)"})
                    }
                } else {
                    sequenceMatrix[i].append(endString[i])
                }
                break
            case .delete:
                sequenceMatrix[i].append("")
                break
            case .add:
                sequenceMatrix[i].append(endString[i])
                break
            case .same:
                sequenceMatrix[i].append(endString[i])
                break
            default:
                sequenceMatrix[i].append("")
                break
            }
        }
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
                sequenceMatrix[i].append(contentsOf: tempSequence)
            }
        }
        let transStr = Array<String>.transpose(input: sequenceMatrix)
        var sequencedStrings = [String]()
        for text in transStr {
            sequencedStrings.append(text.reduce("", +))
        }
        sequencedStrings = sequencedStrings.reversed()
        
        return sequencedStrings
    }
}
