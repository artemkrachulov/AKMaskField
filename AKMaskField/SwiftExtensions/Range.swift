//
//  Range.swift
//  Extension file
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 The Krachulovs. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

extension Range {

    /// Use for converting Range<Int> to NSRange object
    ///
    /// Usage:
    ///
    ///  let range = 10..<15
    ///  println(range.startIndex) // 10
    ///  println(range.endIndex)  // 15
    ///  let convertedRange = range.toNSRange() // (10,5)
    ///  println(convertedRange.location) // 10
    ///  println(convertedRange.length) // 5

    func toNSRange() -> NSRange {
        
        let loc = startIndex as! Int
        
        let len = (endIndex as! Int) - loc
        
        return NSMakeRange(loc, len)
    }
}

/// Use for converting Range<Int> to Range<String.Index> object for target string
///
/// Usage:
///
///  let str = "Hello World!"
///  let convertedRange = converRangeIntToRangeStringIndex(str, 6..<11) // 6..<11

public func converRangeIntToRangeStringIndex(str: String, range: Range<Int>) -> Range<String.Index> {
    
    let range = range.toNSRange()
    
    let start = str.startIndex.advancedBy(range.location)
    let end = start.advancedBy(range.length)
    
    return Range<String.Index>(start: start, end: end)
}