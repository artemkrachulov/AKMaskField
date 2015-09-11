//
//  String.swift
//  Extension file
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 The Krachulovs. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

extension String {
    
    /// Returns a string object containing the characters of the
    /// string that lie within a given range.
    ///
    /// Usage:
    ///   
    ///  let str = "Hello World!"
    ///  let newString = str.subStringWithRange(6..<12) // "World!"
    
    public func subStringWithRange(aRange: Range<Int>) -> String {
        
        return substringWithRange(converRangeIntToRangeStringIndex(self, aRange))
    }
    
    /// Replace the given 'subRange' of elements with 'newElements'
    ///
    /// Usage:
    ///
    ///  var str = "Hello World!"
    ///  str.replaceRange(6..<11, with: "Kitty") // "Hello Kitty!"
    
    mutating func replaceRange(subRange: Range<Int>, with newElements: String) {
    
        replaceRange(converRangeIntToRangeStringIndex(self, subRange), with: newElements)
    }
    
    /// Returns a new string in which all occurrences of a target
    /// string in a specified range of the 'String' are replaced by
    /// another given string.
    ///
    /// Usage:
    ///
    ///  var str = "Hello World, World!"
    ///  str = str.stringByReplacingOccurrencesOfString("World", withString: "Kitty", options: NSStringCompareOptions(0), aRange: 6..<11)
    
    public func stringByReplacingOccurrencesOfString(target: String, withString: String, options: NSStringCompareOptions, aRange: Range<Int>!) -> String {
        
        let range = aRange == nil ? nil : converRangeIntToRangeStringIndex(self, aRange) as Range<String.Index>!
        
        return stringByReplacingOccurrencesOfString(target, withString: withString, options: options, range: range)
    }    
}

