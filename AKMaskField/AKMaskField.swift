//
//  AKMaskField.swift
//  AKMaskField
//
//  Created by Krachulov Artem on 1/10/15.
//  Copyright (c) 2015 The Krachulovs. All rights reserved.
//

import UIKit

/*
-------------------------------
// MARK: Extensions
-------------------------------
*/
extension Range {
    func toNSRange() -> NSRange {
        
        var loc: Int = self.startIndex as Int
        var len: Int = ((self.endIndex as Int) - loc) as Int

        return NSMakeRange(loc, len)
    }
}
extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let start  = advance(self.startIndex, r.startIndex)
            let end    = advance(self.startIndex, r.endIndex - 1)
            
            return self[Range(start: start, end: end)]
        }
    }
    public func convertRange(range: Range<Int>) -> Range<String.Index> {
        let startIndex  = advance(self.startIndex, range.startIndex)
        let endIndex    = advance(startIndex, range.endIndex - range.startIndex)
        return Range<String.Index>(start: startIndex, end: endIndex)
    }
    public func stringByReplacingOccurrencesOfString(target: String, withString: String, options: NSStringCompareOptions, range: Range<Int>) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: options, range: self.convertRange(range))
    }
    public func subStringWithRange(aRange: Range<Int>) -> String {

        return self.substringWithRange(self.convertRange(aRange))
    }
}

/*
-------------------------------
// MARK: Protocol
-------------------------------
*/
@objc protocol AKMaskFieldDelegate {
    optional func maskFieldDidBeginEditing(maskField: AKMaskField)

    optional func maskField(maskField: AKMaskField, madeEvent: String, withText oldText: String, inRange oldTextRange: NSRange, withText newText: String)
    optional func maskField(maskField: AKMaskField, replaceText oldText: String, inRange oldTextRange: NSRange, withText newText: String)
    optional func maskField(maskField: AKMaskField, insertText text: String, inRange range: NSRange)
    optional func maskField(maskField: AKMaskField, deleteText text: String, inRange range: NSRange)
}

/*
-------------------------------
// MARK: Extended class - AKMask
-------------------------------
*/
class AKMaskField: UITextField, UITextFieldDelegate {
    /*
    -------------------------------
    // MARK: Init
    -------------------------------
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Delegates
        self.delegate   = self
    }
    
    /*
    -------------------------------
    // MARK: Properties
    -------------------------------
    */
    
    // Delegate
    var events: AKMaskFieldDelegate?
    
    // Only readable
    private(set) var maskClear                  : String!                           // Ex : (iai)-iiii-aaa
    private      var maskClearCharsLength       : Int       = 0
    private      var maskOut                    : String!
    /*private      var maskOut                    : String! {                         // Ex : (**2)-2342-33*
        get {
            
            
            var p = self.maskPlaceholderText == self._maskPlaceholderText ?
            
            println("self.maskPlaceholderText :\(self.maskPlaceholderText)")
            
            println("self._maskPlaceholderText :\(self._maskPlaceholderText)")
            
            println("self._maskOut :\(self._maskOut)")
            
            
            return self._maskOut != nil ? self._maskOut : self.maskPlaceholderText
        }
        set {
            self._maskOut = newValue
        }
    }*/
    private(set) var maskPlaceholderText       : String!                           // Ex : (***)-****-***
    private(set) var maskObject                : Array<Dictionary<String, Any>>!   // nil
                 var maskStatus                : String! {                         // Clear / Incomplete / Complete
                    get {
                        return self.maskFieldStatus()
                    }
                }
    
    // In-class using
    private var _mask                           : String!
    private var _maskPlaceholder                : String    = "*"
    private var _maskPlaceholderText            : Bool!
    private var _maskShow                       : Bool      = false
    
    // Full access
    @IBInspectable var mask: String! {
        get { return self._mask }
        set {
            
            // Push changes
            self._mask      = newValue
            
            if !newValue.isEmpty {
                
                var _maskClear  : String            = newValue
                let blocks      : Array<AnyObject>  = findMatches(inString: newValue, usingPattern: "\\{(.*?)\\}")
                
                if blocks.count > 0 {
                    
                    var _maskObject = [Dictionary<String, Any>]()
                    
                    for (index: Int, blockObject: AnyObject) in enumerate(blocks) {
                        
                        // Make range
                        let range   : Range<Int> = (blockObject.range as NSRange).toRange()!
                        var start   : Int        = range.startIndex
                        var end     : Int        = range.endIndex
                        
                        // Clear block
                        let clearBlock: String = newValue[start + 1..<end]
                        
                        // Clear block Range
                        if index != 0 {
                            start   -= (index * 2)
                            end     -= (index * 2)
                        }
                        var clearBlockRange: Range<Int> = Range(start: start, end: end)
                        
                        _maskClear = _maskClear.stringByReplacingOccurrencesOfString(
                                        "(.+)",
                            withString: clearBlock,
                            options:    NSStringCompareOptions.RegularExpressionSearch,
                            range:      clearBlockRange
                        )
                        
                        // Create main object for mask
                        clearBlockRange.startIndex  = start
                        clearBlockRange.endIndex    = end - 2

                        // Chars in range
                        var chars = [Dictionary<String, Any> ]()
                        for charIndex in clearBlockRange {
                            
                            self.maskClearCharsLength++
                            
                            chars.append([
                                "range"         : Range(start: charIndex, end: charIndex + 1),
                                "status"        : false
                            ])
                        }
                        
                        _maskObject.append([
                            "status"        : false,
                            "range"         : clearBlockRange,
                            "mask"          : clearBlock,
                            "placeholder"   : "",
                            "chars"         : chars
                        ])
                    }
                    
                    // Push changes
                    self.maskClear  = _maskClear
                    self.maskObject = _maskObject
                    
                    // Set Placeholder
                    self.maskPlaceholder = self._maskPlaceholder
                }
            }
        }
    }
    
    @IBInspectable var maskShow: Bool {
        get { return _maskShow }
        set {
            
            // Push changes
            self._maskShow = newValue
            
            // Refresh
            self.maskFieldUpdate()
        }
    }
    
    @IBInspectable var maskPlaceholder: String {
        get { return _maskPlaceholder }
        set {
            if var _maskObject = self.maskObject {
                
                self._maskPlaceholder = newValue.isEmpty || countElements(newValue) != countElements(self.maskClear) ? "*" : newValue
                
                var _maskPlaceholderText  = self.maskClear
                
                for (blockIndex: Int, block: Dictionary<String, Any>) in enumerate(_maskObject) {
                    
                    var blockRange  : Range<Int> = block["range"] as Range<Int>
                    var placeholder : String     = ""
                    
                    // Create placeholder block
                    if (countElements(self.maskClear) == countElements(_maskPlaceholder))  {
                        placeholder = _maskPlaceholder.subStringWithRange(blockRange)
                    } else  {
                        for _ in blockRange {
                            placeholder += _maskPlaceholder
                        }
                    }
                    
                    _maskPlaceholderText = _maskPlaceholderText.stringByReplacingOccurrencesOfString(
                                    "(.+)",
                        withString: placeholder,
                        options:    NSStringCompareOptions.RegularExpressionSearch,
                        range:      blockRange
                    )
                    
                    _maskObject[blockIndex]["placeholder"] = placeholder
                }
                
                // Push chages
                self.maskObject            = _maskObject
                self.maskPlaceholderText   = _maskPlaceholderText
                
                if self._maskPlaceholder == "*" {
                    self._maskPlaceholderText = true
                }
                
                
                self.maskOut            = _maskPlaceholderText
                
                // Refresh
                self.maskFieldUpdate()
            }
        }
    }
    
    /*
    -------------------------------
    // MARK: Actions
    -------------------------------
    */
    func maskFieldUpdate() {
        if self.maskObject != nil {
 
            var text       : String     = self.text
            var maskOut    : String     = self.maskOut
            
            if !text.isEmpty && maskOut != text {
                self.maskField(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text)
            } else {
                if self.maskShow {
                    self.text   = maskOut
                } else {
                    if self.maskStatus == "Clear" {
                        self.text = ""
                    } else {
                        self.text   = maskOut
                    }
                }
            }
        }
    }
    
    func maskFieldDidBeginEditing(textField: UITextField) {
        if self.maskObject != nil {

            var caret       : Int!
            var position    : UITextPosition!
            
            switch self.maskFieldStatus() {
            case "Complete":
                
                caret = 0
                position = self.endOfDocument
                default:
                    position = self.beginningOfDocument
                    
                    for block: Dictionary<String, Any> in self.maskObject {
                        for char: Dictionary<String, Any>  in block["chars"] as [Dictionary<String, Any>] {
                            
                            if !(char["status"] as Bool) {
                                
                                caret = (char["range"] as Range<Int>).startIndex
                                
                                break
                            }
                        }
                        if caret != nil { break }
                    }
            }
            
            // Set caret to not filled char
            self.selectedTextRange = self.textRangeFromPosition(
                            self.positionFromPosition(position, offset:caret),
                toPosition: self.positionFromPosition(position, offset:caret)
            )
            
            // Delegate
            events?.maskFieldDidBeginEditing?(self)
        }
    }
    
    func maskField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if self.maskObject != nil {
            
            var _maskOut        : String        = self.maskOut
            let range           : Range<Int>    = range.toRange()!
            
            
            let oldText         : String        = _maskOut.subStringWithRange(range)
            
            var oldChar         : Character!

            var maskChar        : Character!
            var maskPattern     : String!
            
            var next            : Bool          = false
            
            var caret           : Int           = range.startIndex
 
            let charsToReplace  : Int           = self.repaceChars(inText: &_maskOut, withRange: range)
            var charsReplaced   : Int           = 0
            
            let newText: String                 = string
            
            for newChar: Character in newText {

                // Break from loop if pasted lenght go out mask
                if caret >= countElements(_maskOut) || (charsToReplace > 0 && charsToReplace == charsReplaced) { break }
                
                // Ignore this if we process new char
                if !next {
                    oldChar = _maskOut[advance(_maskOut.startIndex, caret)]
                }
                
                // If block char
                var (inBlock, _blockIndex, _rangeIndex) = self.inBlock(caret)
                
                
                if oldChar == newChar && !inBlock {
                    caret++
                } else {
                    
                    // Ignore this if we process new char
                    if !next {
                        
                        // Caret in block
                        if caret <= _rangeIndex {
                            caret = _rangeIndex
                        }
                        
                        if _blockIndex == nil || _rangeIndex == nil { caret = countElements(_maskOut); break }

                        maskChar = self.maskClear[advance(self.maskClear.startIndex, caret)]
                        
                        // Check char with pattern
                        switch maskChar {
                        case "d":
                            maskPattern = "\\d"         // Number, Decimal Digit
                        case "D":
                            maskPattern = "\\D"         // Match any character that is not a decimal digit
                        case "W":
                            maskPattern = "\\W"         // Match a non-word character
                        case "a":
                            maskPattern = "[a-zA-Z]"    // Match alphabet
                        default:
                            maskPattern = "."           // Match any character
                        }

                    }
                    
                    if findMatches(inString: String(newChar), usingPattern: maskPattern).count == 0 {
                        next = true
                    } else {
                        next = false

                        // Update out text
                        _maskOut = _maskOut.stringByReplacingOccurrencesOfString(
                                        ".",
                            withString: String(newChar),
                            options:    NSStringCompareOptions.RegularExpressionSearch,
                            range:      Range(start:  caret, end: caret + 1)
                        )
                        
                        // Set empty char to false
                        updateChars(inBlock: _blockIndex, withId: caret - _rangeIndex, toState: true)
                        
                        // Update replaced chars
                        charsReplaced++
                    
                        caret++
                        
                    }
                }
            }
            
            // Set new text
            self.maskOut    = _maskOut
            self.text       = _maskOut
            
            // Move caret to new position if field on focus
            if let position: UITextPosition = self.beginningOfDocument {
                let caretPosition       = self.positionFromPosition(position, offset: caret)
                self.selectedTextRange  = self.textRangeFromPosition(
                                caretPosition,
                    toPosition: caretPosition
                )
            }

            // Event
            var event: String!
            if charsReplaced == charsToReplace && caret == range.startIndex {
                event = "Error"
            } else if charsReplaced != 0 && charsToReplace != 0 {
                event = "Replace"
            } else if charsReplaced == 0  {
                event = "Delete"
            } else {
                event = "Insert"
            }
            
            // Update View
            self.maskFieldUpdate()
            
            // Event
            if event != nil {
                events?.maskField?(
                                self,
                    madeEvent:  event,
                    withText:   oldText,
                    inRange:    range.toNSRange(),
                    withText:   newText
                )
            }
            
            return false
            
        } else {
            return true
        }
    }
    
    /*
    -------------------------------
    // MARK: Help methods
    -------------------------------
    */
    private func maskFieldStatus() -> String {
        
        var status: String = "Error: No mask found"
        
        if let _maskObject = self.maskObject {
            
            // Detect count of filled characters
            var charsFilled: Int = 0
            
            for block: Dictionary<String, Any> in _maskObject {
                for char: Dictionary<String, Any> in block["chars"] as [Dictionary<String, Any>]  {
                    if char["status"] as Bool { charsFilled++ }
                }
            }
            
            // Set status
            if charsFilled == 0 {
                status = "Clear"
            } else if charsFilled >= self.maskClearCharsLength {
                status = "Complete"
            } else {
                status = "Incomplete"
            }
        }
        return status
    }
    
    private func inBlock(caret: Int) -> (inBlock: Bool, _blockIndex: Int!, _rangeIndex: Int!) {
        
        var _blockIndex     : Int!
        var _rangeIndex     : Int!
        
        var inBlock         : Bool!
        
        for (blockIndex: Int, block:Dictionary<String, Any>) in enumerate(self.maskObject) {
            
            let blockRange = block["range"] as Range<Int>
            
            if caret >= blockRange.startIndex && caret < blockRange.endIndex {
                
                // Carets for char updates
                _blockIndex = blockIndex
                _rangeIndex = blockRange.startIndex
                
                inBlock = true
                
                break
            } else {
                inBlock = false
                
                if caret <= blockRange.startIndex {
                    
                    // Carets for char updates
                    _blockIndex = blockIndex
                    _rangeIndex = blockRange.startIndex
                    
                    break
                }
            }
        }
        
        return (inBlock, _blockIndex, _rangeIndex)    
    }
    
    private func findMatches(inString string: String, usingPattern pattern: String) -> [AnyObject] {
        
        var error       : NSError?
        let expression  : NSRegularExpression = NSRegularExpression(
            pattern:        pattern,
            options:        NSRegularExpressionOptions.CaseInsensitive,
            error:          &error
        )!
        let matches     = expression.matchesInString(
                            string,
            options:        nil,
            range:          NSMakeRange(0, countElements(string))
        )
        return matches
    }

    private func updateChars(inBlock blockId: Int, withId charId: Int, toState state: Bool) {
        
        var block = (self.maskObject[blockId] as Dictionary<String, Any>)
        var chars = block["chars"] as [Dictionary<String, Any>]
        
        chars[charId]["status"] = state
        
        self.maskObject[blockId]["chars"] = chars
        
        // Can be removed
        var charsFilled: Int = 0
        for char in chars {
             if char["status"] as Bool { charsFilled++ }
        }
        if distance((block["range"] as Range<Int>).startIndex, (block["range"] as Range<Int>).endIndex) == charsFilled  {
            self.maskObject[blockId]["status"] = true
        } else {
            self.maskObject[blockId]["status"] = false
        }
    }
    
    private func repaceChars(inout inText text: String, withRange range: Range<Int>) -> Int {
    
        var charsToReplace: Int = 0
        if distance(range.startIndex, range.endIndex) > 0 {
            
         
            // Replace chars to placeholder
            for rangeIndex: Int in range {
                
                let maskClearRange: Range<Int>  = Range(start: rangeIndex, end: rangeIndex + 1)
                let maskClearChar: String       = self.maskPlaceholderText.subStringWithRange(maskClearRange)
                
                text = text.stringByReplacingOccurrencesOfString(
                                ".",
                    withString: maskClearChar,
                    options:    NSStringCompareOptions.RegularExpressionSearch,
                    range:      maskClearRange
                )
                
                for (blockIndex: Int, block:Dictionary<String, Any>) in enumerate(self.maskObject!) {
                    
                    let blockRange = block["range"] as Range<Int>
                    
                    if  rangeIndex >= blockRange.startIndex && rangeIndex < blockRange.endIndex {

                        // Set empty char to false
                        updateChars(inBlock: blockIndex, withId: rangeIndex - blockRange.startIndex, toState: false)
                        
                        break
                    }
                }
                charsToReplace++
            }
            
        }
        
        return charsToReplace
    }

    /*
    -------------------------------
    // MARK: Delegates
    -------------------------------
    */
    func textFieldDidBeginEditing(textField: UITextField) {
        self.maskFieldDidBeginEditing(textField)
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return self.maskField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}

