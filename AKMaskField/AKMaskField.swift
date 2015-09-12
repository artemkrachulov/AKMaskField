//
//  AKMaskField.swift
//  AKMaskField
//
//  Created by Krachulov Artem on 1/10/15.
//  Copyright (c) 2015 The Krachulovs. All rights reserved.
//

import UIKit

// MARK: - Extension
// --------------------------------------------------------------------------------------------------- //





// MARK: - Enums
// --------------------------------------------------------------------------------------------------- //

enum AKMaskFieldEvets {
    
    case None
    case Insert
    case Delete
    case Replace
    
    case Update
}

enum AKMaskFieldStatus {
    
    case Clear
    case Incomplete
    case Complete
}

/* Structs for MaskObject */

struct AKMaskFieldBlock {
    
    var index: Int
    var status: Bool
    var range: Range<Int>
    var mask: String
    var text: String
    var template: String
    var chars: [AKMaskFieldBlockChars]
}

struct AKMaskFieldBlockChars {
    
    var index: Int
    var status: Bool
    var text: Character
    var range: Range<Int>
}



// MARK: - AKMaskFieldDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _


@objc protocol AKMaskFieldDelegate {
    
    optional func maskFieldDidBeginEditing(maskField: AKMaskField)
    optional func maskField(maskField: AKMaskField, shouldChangeCharacters oldString: String, inRange range: NSRange, replacementString withString: String)
}

// MARK: - Class
// --------------------------------------------------------------------------------------------------- //
class AKMaskField: UITextField {
    
    
    
    /// String value with brackets
    ///
    /// Usage
    ///
    ///  field.mask = "{dddd}-{ddddd}-{dddd}-{dddd}"
    @IBInspectable var mask: String {
        get { return _mask }
        set {
            
            // Save value
            _mask = newValue
            
            if !_mask.isEmpty {
                
                // Reset mask object
                reset()
                
                // Brackets
                let leftBracket = String(maskBlockBrackets[0])
                let rightBracket = String(maskBlockBrackets[1])
                
                // Copy mask and strip left and right bracket
                maskWithoutBrackets = _mask.stringByReplacingOccurrencesOfString("[" + leftBracket + rightBracket + "}]", withString: "", options: .RegularExpressionSearch, range: nil)
                
                let blocks = findMatches(inString: newValue, usingPattern: "(?<=\\" + leftBracket + ").*?(?=\\" + rightBracket + ")")
                
                if blocks.count > 0 {
                    for (i, block: AnyObject) in enumerate(blocks) {
                        
                        let range = (block.range as NSRange).toRange()!
                        
                        let multiplier = (i * 2) + 1
                        
                        let bRange = range.startIndex - multiplier..<range.endIndex - multiplier
                        
                        // Process block characters
                        var chars = [AKMaskFieldBlockChars]()
                        
                        for (y, index) in enumerate(bRange) {
                            
                            chars.append(AKMaskFieldBlockChars(index: y, status: false, text: maskTemplateDefaultChar, range: index..<index+1))
                        }
                        
                        // Process blocks
                        maskObject.append(AKMaskFieldBlock(index: i, status: false, range: bRange, mask: _mask.subStringWithRange(range), text: "", template: "", chars: chars))
                    }
                    
                    // Set Placeholder
                    maskTemplate = _maskTemplate ?? String(maskTemplateDefaultChar)
                }
            }
        }
    }
    
    /// Mask template status
    ///
    /// Usage
    ///
    ///  maskShowTemplate = true
    @IBInspectable var maskShowTemplate: Bool {
        get { return _maskShowTemplate }
        set {
            
            // Save value
            _maskShowTemplate = newValue
            
            // Reset text value if mask template property has been changed
            if !_maskShowTemplate {
                
                text = ""
            }
            
            // Refresh
            refresh()
        }
    }
    
    /// Mask template status
    ///
    /// Usage
    ///
    ///  maskShowTemplate = true
    @IBInspectable var maskTemplate: String {
        get { return _maskTemplate }
        set {
            
            _maskTemplate = newValue
            
            // Check mask object
            if maskObject.count > 0 {
                
                // Save mask
                maskTemplateText = maskWithoutBrackets
                
                // Replace default charachter
                var copy = true
                var copyChar = String(maskTemplateDefaultChar)
                
                if count(_maskTemplate) == count(maskWithoutBrackets) {
                    copy = false
                } else {
                    if count(_maskTemplate) == 1 {
                        copyChar = _maskTemplate
                    }
                }
                
                for (i, block) in enumerate(maskObject) {
                    
                    let range = block.range
                    
                    // Prepare template
                    var template = ""
                    if copy {
                        for _ in range {
                            template += copyChar
                        }
                    } else  {
                        template = _maskTemplate.subStringWithRange(range)
                    }
                    
                    // Save changes to value
                    maskTemplateText = maskTemplateText.stringByReplacingOccurrencesOfString("(.+)", withString: template, options: .RegularExpressionSearch, aRange: range)
                    
                    // Replace character to new template character
                    var chars = maskObject[i].chars
                    for (y, char) in enumerate(template) {
                        
                        chars[y].text = char
                    }
                    
                    // Update mask object
                    maskObject[i].template = template
                    maskObject[i].text = template
                    maskObject[i].chars = chars
                }
                
                // Save pocessed mask text
                maskText = maskTemplateText
                
                // Save object if in future user will clear mask field
                maskObjectClear = maskObject
                
                // Set new text
                maskField(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text)
            }
        }
    }
    

    
    
    
    
    
    
    
    
    

    
    // MARK: - Properties
    // --------------------------------------------------------------------------------------------------- //
    
    /* Protocol */
    var maskDelegate: AKMaskFieldDelegate?
    
    /* */
    private(set) var maskStatus: AKMaskFieldStatus = .Clear
    
    private(set) var maskEvent: AKMaskFieldEvets = .None
    
    
    
    // Flags
    private var flagUpdateEvent: Bool!

    
    
    
    // MARK: -  Configuring mask
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    var maskBlockBrackets: [Character] = ["{", "}"]
    
    
    
    
    
    
    
    private var _mask: String!
    
    private(set) var maskText: String!
    
    private(set) var maskObject = [AKMaskFieldBlock]()
    
    /*  - - - - - - - - - - - - - - -- - - - - - -
        Copy of maskObjectproperty after mask initialisation
        Using, if need to clear field
    */
    
    private var maskObjectClear = [AKMaskFieldBlock]()
    
    private(set) var maskWithoutBrackets: String!
    
    private var _maskShowTemplate  = false
    
    private var _maskTemplate: String!
    
    private(set) var maskTemplateText: String!
    
    private var maskTemplateDefaultChar: Character = "*"
    
    
    
    // MARK: - Draw
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        delegate = self
        
        // This observer used on manual updatind text property
        addObserver(self, forKeyPath: "text", options: nil, context: nil)
    }
    

    
    
    
    func refresh() {

        if maskObject.count > 0 && maskText != text {
            if maskShowTemplate {
                text = maskText
            } else {
                text = maskStatus == .Clear ? "" : maskText
            }
        }
        
        // Reset manual updating property flag
        flagUpdateEvent = true
    }
    
    func reset() {
        
        maskObject = [AKMaskFieldBlock]()
        text = ""
    }
    
    
    
    
    
    func maskFieldDidBeginEditing(textField: UITextField) {
        
        if maskObject.count > 0 {

            var position = 0
//            var position = beginningOfDocument
            
            switch maskStatus {
                case .Complete:
                    
                    position = count(maskTemplateText)
//                    position = endOfDocument
                
                case .Incomplete:
//                    position = beginningOfDocument
                    
                    for block in maskObject {
                        for char in block.chars {
                            
                            
                            if !char.status {
                                
                                position = char.range.startIndex
                                
                                break
                            }
                        }
                        if position != 0 { break }
                    }
                default: ()
            }
            
            // Move caret to new position if field on focus
             moveCaretToPosition(position)
            
            // Delegate
            maskDelegate?.maskFieldDidBeginEditing?(self)
        }
    }
    
    func maskField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Set flags
        flagUpdateEvent = false
        
        // Change chars
        if maskObject.count > 0 {

            let range = range.toRange()!
            
            // Copy
            var _maskText = maskText as String
            let charactersToChange = _maskText.subStringWithRange(range)
            
            // Step 1
            // Replace current string with template string
            _maskText = _maskText.stringByReplacingOccurrencesOfString(".+", withString: maskTemplateText.subStringWithRange(range), options: .RegularExpressionSearch, aRange: range)
            
            // Step 2
            // Clear exist chars in text, with replacing with mask template char
            resetStringInRange(range)
            
            // Step 3
            // Replace current string with new one
            let chars = replaceStringInRange(&_maskText, range: range, bStr: string)
            
            // Step 4
            // Save
            maskText = _maskText
            
            // Step 5
            // Set current event to property
            
            var event: AKMaskFieldEvets!
            if chars.replaced == chars.toReplace && chars.position == range.startIndex {
                if  chars.position == 0 && range.startIndex == 0 {
                    
                    maskEvent = .Delete
                } else {
                    maskEvent = .None
                }
            } else if  chars.replaced != 0 &&  chars.toReplace != 0 {                
                maskEvent = .Replace
            } else if  chars.replaced == 0  {
                if  chars.position != range.startIndex {
                    maskEvent = .Insert
                } else {
                    maskEvent = .Delete
                }
            } else {
                maskEvent = .Insert
            }
            
            // Step 6
            // Set current status to property
            
            var filled = 0
            var total = 0
            
            for block in maskObject {
                for char in block.chars  {
                    if char.status {
                        filled++
                    }
                }
                total += block.range.toNSRange().length
            }
            if filled == 0 {
                maskStatus = .Clear
                
            } else if filled == total {
                maskStatus = .Complete
                
            } else {
                maskStatus = .Incomplete
            }
            
            // Step 7
            // Refresh field
            refresh()
                
            // Step 8
            // Move caret to new position if field on focus
            
            moveCaretToPosition(chars.position)
            
            // Step 9
            // Send delegate
            maskDelegate?.maskField!(self, shouldChangeCharacters: charactersToChange, inRange: range.toNSRange(), replacementString: string)
        
            return false
            
        } else {
            
            return true
        }
    }
    
    // MARK: - Helper Methods
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    private func resetStringInRange(range: Range<Int>) {
        
        if range.toNSRange().length > 0 {
            for index in range {
                
                for block in maskObject {
                    
                    let blockRange = block.range
                    
                    if  index >= blockRange.startIndex && index < blockRange.endIndex {
                        
                        // Set empty char to false
                        updateBlock(block, character: nil, atIndex: index - blockRange.startIndex)
                        
                        break
                    }
                }
            }
        }
    }
    
    private func replaceStringInRange(inout aStr:String, range: Range<Int>, bStr: String) -> (position: Int, toReplace: Int, replaced:Int) {
        
        var oldChar: Character!
        
        var pattern = "."
        let charsToReplace = range.toNSRange().length
        
        // Flags
        var flagNextChar = false
        
        // Counters
        var charsReplaced = 0
        var position = range.startIndex
        
        // Process
        for char: Character in bStr {
            
            // Break from loop if pasted lenght go out mask
            if position >= count(aStr) || (charsToReplace > 0 && charsToReplace == charsReplaced) { break }
            
            // Ignore this if we process new char
            if !flagNextChar {
                oldChar = aStr[advance(aStr.startIndex, position)]
            }
            
            // Get block with caret
            let (active, block) = activeBlock(position)
            
            let startPosition = block.range.startIndex
            
            if oldChar == char && !active {
                
                position++
            } else {
                
                // Ignore this if we process new char
                if !flagNextChar {
                    
                    // Set position to block start index
                    position = max(position, startPosition)
                    
                    // Check char with pattern
                    switch maskWithoutBrackets.subStringWithRange(position...position) {
                        case "d":
                            pattern = "\\d"         // Number, Decimal Digit
                        case "D":
                            pattern = "\\D"         // Match any character that is not a decimal digit
                        case "W":
                            pattern = "\\W"         // Match a non-word character
                        case "a":
                            pattern = "[a-zA-Z]"    // Match alphabet
                        default: ()
                    }
                }
                
                if findMatches(inString: String(char), usingPattern: pattern).count == 0 {
                    flagNextChar = true
                    
                } else {
                    
                    flagNextChar = false
                    
                    aStr = aStr.stringByReplacingOccurrencesOfString(".", withString: String(char), options: .RegularExpressionSearch, aRange: Range(start:  position, end: position + 1))
                    
                    // Update charachter state
                    updateBlock(block, character: char, atIndex: position - startPosition)
                    
                    // Update ounters
                    charsReplaced++
                    position++
                }
            }
        }
        return (position, charsToReplace, charsReplaced)
    }
    
    private func activeBlock(caret: Int) -> (active: Bool, block: AKMaskFieldBlock) {
        
        var _block: AKMaskFieldBlock!
        var active: Bool!
        
        for (i, block) in enumerate(maskObject) {
            
            let blockRange = block.range
            
            if caret >= blockRange.startIndex && caret < blockRange.endIndex {
                
                _block = block
                active = true
                
                break
            } else {
                active = false
                
                if caret <= blockRange.startIndex {
                    
                    _block = block
                    
                    break
                }
            }
        }
        
        return (active, _block)
    }
    
    private func findMatches(inString string: String, usingPattern pattern: String) -> [AnyObject] {
        
        var error : NSError?
        
        let expression : NSRegularExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
        
        let matches = expression.matchesInString(string, options: nil, range: NSMakeRange(0, count(string)))
        
        return matches
    }
    
    private func moveCaretToPosition(position: Int) {
    
        if let beginningOfDocument: UITextPosition = self.beginningOfDocument {
            
            let caretPosition = self.positionFromPosition(beginningOfDocument, offset: position)
            self.selectedTextRange  = self.textRangeFromPosition(caretPosition, toPosition: caretPosition)
        }
    }

    private func updateBlock(block: AKMaskFieldBlock, character: Character!, atIndex index: Int) {
    
        // Copy
        var chars = block.chars
        var text = block.text
        
        // Check char
        let isChar = character != nil        
        
        // Switch to mask char if nil
        let newChar = isChar ? String(character) : block.template.subStringWithRange(index..<index+1)
        text.replaceRange(index..<index+1, with: newChar)

        // Save
        chars[index].text = Character(newChar)
        chars[index].status = isChar
        
        // Update Block Status        
        var charsFilled: Int = 0
        for char in chars {
            if char.status {
                
                charsFilled++
            }
        }
        
        maskObject[block.index].status = block.range.toNSRange().length == charsFilled
        maskObject[block.index].text = text
        maskObject[block.index].chars = chars
    }
}


// MARK: - Observers
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKMaskField {

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if (keyPath == "text" && object === self && flagUpdateEvent == true) {
            
            /*  Reset data on manual updating */
            
            maskText = maskTemplateText
            
            maskObject = maskObjectClear
            
            /* Process field */
            self.maskField(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text)
        }
    }
}

// MARK: - UITextFieldDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKMaskField: UITextFieldDelegate {

    func textFieldDidBeginEditing(textField: UITextField) {
        maskFieldDidBeginEditing(textField)
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return maskField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}
