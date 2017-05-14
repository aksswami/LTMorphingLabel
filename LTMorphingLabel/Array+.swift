//
//  Array+.swift
//  LTMorphingLabelDemo
//
//  Created by Amit kumar Swami on 09/01/17.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

import Foundation

extension Array {
    public static func transpose<T>(input: [[T]]) -> [[T]] {
        if input.isEmpty { return [[T]]() }
        let count = input[0].count
        var out = [[T]](repeating: [T](), count: count)
        for outer in input {
            for (index, inner) in outer.enumerated() {
                out[index].append(inner)
            }
        }
        
        return out
    }
}
