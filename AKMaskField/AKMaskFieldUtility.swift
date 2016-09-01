//
//  AKMaskFieldUtility.swift
//  AKMaskField
//  GitHub: https://github.com/artemkrachulov/AKMaskField
//
//  Created by Artem Krachulov
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class AKMaskFieldUtility {

  /// [Source](http://stackoverflow.com/questions/25138339/nsrange-to-rangestring-index)
  class func rangeFromString(string: String, nsRange: NSRange) -> Range<String.Index>! {
    let from16 = string.utf16.startIndex.advancedBy(nsRange.location, limit: string.utf16.endIndex)
    let to16 = from16.advancedBy(nsRange.length, limit: string.utf16.endIndex)
    
    if let from = String.Index(from16, within: string),
      let to = String.Index(to16, within: string) {
      return from ..< to
    }
    return nil
  }
  
  class func substring(sourceString: String?, withNSRange range: NSRange) -> String {
    guard let sourceString = sourceString else {
      return ""
    }
    return sourceString.substringWithRange(rangeFromString(sourceString, nsRange: range))
  }
  
  class func replace(inout sourceString: String!, withString string: String, inRange range: NSRange) {
    sourceString = sourceString.stringByReplacingCharactersInRange(rangeFromString(sourceString, nsRange: range), withString: string)
  }
  
  class func replacingOccurrencesOfString(inout string: String!, target: String, withString replacement: String) {    
    string = string.stringByReplacingOccurrencesOfString(target, withString: replacement, options: .RegularExpressionSearch, range: nil)
  }
  
  class func maskField(maskField: UITextField, moveCaretToPosition position: Int) {
    guard let caretPosition = maskField.positionFromPosition(maskField.beginningOfDocument, offset: position) else {
      return
    }
    
    maskField.selectedTextRange = maskField.textRangeFromPosition(caretPosition, toPosition: caretPosition)
  }
  
  class func matchesInString(string: String, pattern: String) -> [NSTextCheckingResult] {
    return  try!
      NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        .matchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, string.characters.count))
  }
  
  class func findIntersection(ranges: [NSRange], withRange range: NSRange) -> [NSRange?] {
    
    var intersectRanges = [NSRange?]()
    
    for r in ranges {
      
      var intersectRange: NSRange!
      
      let delta = r.location - range.location
      var location, length, tail: Int
      
      if delta <= 0 {
        location = range.location
        length   = range.length
        tail     = r.length - abs(delta)
      } else {
        location = r.location
        length   = r.length
        tail     = range.length - abs(delta)
      }
      
      if tail > 0 && length > 0 {
        intersectRange = NSMakeRange(location, min(tail, length))
      }
      
      intersectRanges.append(intersectRange)
    }
    return intersectRanges
  } 
}