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
  
  //  MARK: - Range+Extension.swift
  
  /// Convert to NSRange object.
  ///
  /// Usage:
  ///
  ///     let range = 10..<15 // 10..<15
  ///     let convertedRange = range.toNSRange() // (10,5)
  class func toNSRange(range: Range<Int>) -> NSRange {
    let loc = range.startIndex
    let len = range.endIndex - loc
    return NSMakeRange(loc, len)
  }
  
  /// Convert Range<Int> to Range<String.Index> object
  ///
  /// Usage:
  ///
  ///     let str = "Hello World!"
  ///     let toRangeStringIndex = converRangeIntToRangeStringIndex(str, range: 6..<11) // 6..<11
  class func rangeIntToRangeStringIndex(str: String, range: Range<Int>) -> Range<String.Index>? {
    guard range.startIndex <= str.characters.count && range.endIndex <= str.characters.count else {
      return nil
    }
    return Range<String.Index>(str.startIndex.advancedBy(range.startIndex)..<str.startIndex.advancedBy(range.endIndex))
  }
  
  //  MARK: -
  
  class func matchesInString(string: String, usingPattern pattern: String) -> [NSTextCheckingResult] {
    let expression = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    return expression.matchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, string.characters.count))
  }
 
  class func moveCaretToPosition(position: Int, inField field: AKMaskField) -> UITextRange?  {
    if let beginningOfDocument: UITextPosition = field.beginningOfDocument {
      let caretPosition = field.positionFromPosition(beginningOfDocument, offset: position)
      return field.textRangeFromPosition(caretPosition!, toPosition: caretPosition!)
    }
    return nil
  }
  
  class func replaceOccurrencesInString(string: String, usingPattern pattern: String, withString replacement: String, range searchRange: Range<Int>!) -> String {
    return string.stringByReplacingOccurrencesOfString(pattern,
                                                withString: replacement,
                                                options: .RegularExpressionSearch,
                                                range: searchRange == nil ? nil : rangeIntToRangeStringIndex(string, range: searchRange))
  }
  
  class func substringString(string: String, withRange range: Range<Int>) -> String {
    return string.substringWithRange(rangeIntToRangeStringIndex(string, range: range)!)
  }
}