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

extension Range {
    func toNSRange() -> NSRange {
        
        let loc: Int = self.startIndex as! Int
        
        let len: Int = ((self.endIndex as! Int) - loc) as Int

        return NSMakeRange(loc, len)
    }
}

extension String {
    
    public func convertRange(range: Range<Int>) -> Range<String.Index> {
        
        let startIndex = advance(self.startIndex, range.startIndex)
        
        let endIndex = advance(startIndex, range.endIndex - range.startIndex)
        
        return Range<String.Index>(start: startIndex, end: endIndex)
    }
    
    public func stringByReplacingOccurrencesOfString(target: String, withString: String, options: NSStringCompareOptions, range: Range<Int>) -> String {
        
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: options, range: self.convertRange(range))
    }
    
    public func subStringWithRange(aRange: Range<Int>) -> String {

        return self.substringWithRange(self.convertRange(aRange))
    }
}

// MARK: - Enums
// --------------------------------------------------------------------------------------------------- //

enum AKMaskFieldSEvets {
    
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

// MARK: - Protocol
// --------------------------------------------------------------------------------------------------- //

@objc protocol AKMaskFieldDelegate {
    
    optional func maskFieldDidBeginEditing(maskField: AKMaskField)
    
    optional func maskField(maskField: AKMaskField, shouldChangeCharacters oldString: String, InRange range: NSRange, replacementString withString: String)
}

// MARK: - Class
// --------------------------------------------------------------------------------------------------- //
class AKMaskField: UITextField, UITextFieldDelegate {
    
    /* Structs for MaskObject */
    
    struct AKMaskFieldBlock {
        var index: Int
        var status: Bool
        var range: Range<Int>
        var mask: String
        var text: String
        var placeholder: String
        var chars: [AKMaskFieldBlockChars]
    }
    
    struct AKMaskFieldBlockChars {
        var status: Bool
        var range: Range<Int>
    }
    
    // MARK: - Properties
    // --------------------------------------------------------------------------------------------------- //
    
    /* Protocol */
    var maskDelegate: AKMaskFieldDelegate?
    
    /* */
    private(set) var maskFieldStatus : AKMaskFieldStatus = .Clear
    
    private(set) var maskFieldEvent : AKMaskFieldSEvets = .None
    
    private var isUpdateEvent: Bool!

    /* Settings */
    
    var maskBlockBrackets: [Character] = ["{","}"]
    
    private var _mask: String!
    
    private(set) var maskText: String!
    
    private(set) var maskObject = [AKMaskFieldBlock]()
    
    /*  - - - - - - - - - - - - - - -- - - - - - -
        Copy of maskObjectproperty after mask initialisation
        Using, if need to clear field
    */
    
    private var maskObjectClear = [AKMaskFieldBlock]()
    
    private(set) var maskWithoutBrackets: String!
    
    private var _maskShow  = false
    
    private var _maskTemplate: String!
    
    private(set) var maskTemplateText: String!
    
    private var maskTemplateDefaultChar: Character = "*"
    
    
    /*  Attributes inspector */
    
    /*  - - - - - - - - - - - - - - -- - - - - - -
        Mask
    
        Example: {dddd}-{ddddd}-{dddd}-{dddd}
    */
    
    @IBInspectable var mask: String! {
        get {
            
            return self._mask
        }
        set {
            
            // Push changes
            self._mask = newValue
            
            if !newValue.isEmpty {
                
                // Save clear mask without brackets
                maskWithoutBrackets = newValue
                
                for bracket in maskBlockBrackets {
                    maskWithoutBrackets = maskWithoutBrackets.stringByReplacingOccurrencesOfString(String(bracket), withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                }
                
                let lBracket = String(maskBlockBrackets[0])
                let rBracket = String(maskBlockBrackets[1])
                
                let blocks = findMatches(inString: newValue, usingPattern: "(?<=\\" + lBracket + ").*?(?=\\" + rBracket + ")")
                
                if blocks.count > 0 {
                    
                    for (i, block: AnyObject) in enumerate(blocks) {
                        
                        let blockRange = (block.range as NSRange).toRange()!
                        
                        let blockMask = newValue.subStringWithRange(blockRange)
                        
                        var chars = [AKMaskFieldBlockChars]()
                        
                        for y in blockRange {
                            
                            var charObject = AKMaskFieldBlockChars(
                                status : false,
                                range : Range(start: y - 1, end: y)
                            )
                        
                            chars.append(charObject)
                        }
          
                        var blockObject = AKMaskFieldBlock(
                            index : i,
                            status : false,
                            range : Range(start: blockRange.startIndex - (i * 2) - 1, end: blockRange.endIndex - (i * 2) - 1 ),
                            mask : blockMask,
                            text : "",
                            placeholder : "",
                            chars : chars
                        )
                        
                        maskObject.append(blockObject)
                        
                        maskObjectClear = maskObject
                    }
                    
                    // Set Placeholder
                    self.maskTemplate = String(maskTemplateDefaultChar)
                }
            }
        }
    }
    
    /*  - - - - - - - - - - - - - - -- - - - - - -
        Show template
    
        Example: True / False
    */
    
    @IBInspectable var maskShow: Bool {
        get {
            
            return _maskShow
        }
        set {
            
            _maskShow = newValue
            
            /* Refresh */
            
            self.updateMaskField()
        }
    }
    
    /*  - - - - - - - - - - - - - - -- - - - - - -
        Template
    
        Example: ****-****-****-*****
        Example: *
    */
    
    @IBInspectable var maskTemplate: String {
        get {
            
            return self._maskTemplate
        }
        set {
            
            _maskTemplate = newValue
            
            if self.maskObject.count > 0 {
                
                maskTemplateText = maskWithoutBrackets
                
                var useTempaleChar = false
                if !newValue.isEmpty || count(newValue) != count(maskWithoutBrackets) {
                    
                    useTempaleChar = true
                }
                
                for (i, block) in enumerate(maskObject) {
                    
                    let blockRange = block.range
                    var blockTemplate = ""
                    
                    if (useTempaleChar)  {
                        
                        for _ in blockRange {
                            
                            blockTemplate += String(maskTemplateDefaultChar)
                        }
                    } else  {
                        
                        blockTemplate = newValue.subStringWithRange(blockRange)
                    }
                    
                    maskTemplateText = maskTemplateText.stringByReplacingOccurrencesOfString("(.+)", withString: blockTemplate, options: .RegularExpressionSearch, range:blockRange)
                    
                    maskObject[i].placeholder = blockTemplate
                }
                
                /* Save pocessed mask text */
                
                maskText = maskTemplateText
                
                /* Refresh */
                
                maskField(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text)
            }
        }
    }
    
    // MARK: - Overrides
    // -------------------------------------------------------------------------------------------------- //
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.delegate = self
        
        /*  - - - - - - - - - - - - - - - - - - - - - - - - - - -
            This observer used on manual updatind text property
        */
        
        self.addObserver(self, forKeyPath: "text", options: nil, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if (keyPath == "text" && object === self && isUpdateEvent == true) {
            
            /*  Reset data on manual updating */
            
            maskText = maskTemplateText
    
            maskObject = maskObjectClear
            
            /* Process field */
            
            self.maskField(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text)
        }
    }
    
    func updateMaskField() {
        if self.maskObject.count > 0 && maskText != text {
            
            if maskShow {
                
                text = maskText
                
            } else {
                
                self.text = maskFieldStatus == .Clear ? "" : maskText
            }
        }
        
        /* Reset manual updating property */
        
        isUpdateEvent = true
    }
    
    
    func maskFieldDidBeginEditing(textField: UITextField) {
        
        if self.maskObject.count > 0 {

            var caret: Int = 0
            var position = self.beginningOfDocument
            
            switch maskFieldStatus {
                case .Complete:
                    
                    caret = count(maskTemplateText)
                    position = self.endOfDocument
                
                case .Incomplete:
                    position = self.beginningOfDocument
                    
                    for block in self.maskObject {
                        for char in block.chars {
                            
                            if !char.status {
                                
                                caret = char.range.startIndex
                                
                                break
                            }
                        }
                        if caret != 0 { break }
                    }
                default: ()
            }
            
            /* Move caret to new position if field on focus */
            
             moveCaretToPosition(caret)
            
            // Delegate
            maskDelegate?.maskFieldDidBeginEditing?(self)
        }
    }
    
    func maskField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        /* Block manual updating property */
        
        isUpdateEvent = false
        
        /* Process */
        
        if maskObject.count > 0 {
            
            /* Copy property */
            
            var _maskText = maskText as String
    
            let newText = string
        
            let range = range.toRange()!
            
            let oldText  = _maskText.subStringWithRange(range)
            
            var oldChar: Character!

            var maskChar: Character!
            
            var maskPattern = "."
            
            var processNextChar = false
 
            let charsToReplace: Int = range.toNSRange().length
            
            var charsReplaced: Int = 0
            
            var caretPosition = range.startIndex
            
            /* Replace current text with template */
            
            _maskText = _maskText.stringByReplacingOccurrencesOfString(".+", withString: maskTemplateText.subStringWithRange(range), options: .RegularExpressionSearch, range: range)
            
            resetText(inRange: range)
            
            /* Replace current Character with noew one */
            
            for newChar: Character in newText {

                /* Break from loop if pasted lenght go out mask */
                
                if caretPosition >= count(_maskText) || (charsToReplace > 0 && charsToReplace == charsReplaced) {
                    
                    break
                }
                
                /* Ignore this if we process new char */
                
                if !processNextChar {
                    
                    oldChar = _maskText[advance(_maskText.startIndex, caretPosition)]
                }
                
                /* Get block if caret inside */
                
                let (active, block) = activeBlock(caretPosition)
                
                let blockRangeStart = block.range.startIndex
                
                if oldChar == newChar && !active {
                    
                    caretPosition++
                } else {
                    
                    /* Ignore this if we process new char */
                    
                    if !processNextChar {
                        
                        /* Set caretPosition to block start index */
                        if caretPosition <= blockRangeStart {
                            
                            caretPosition = blockRangeStart
                        }
                        
                        maskChar = self.maskWithoutBrackets[advance(self.maskWithoutBrackets.startIndex, caretPosition)]
                        
                        /* Check char with pattern */
                        
                        switch maskChar {
                            case "d":
                                maskPattern = "\\d"         // Number, Decimal Digit
                            case "D":
                                maskPattern = "\\D"         // Match any character that is not a decimal digit
                            case "W":
                                maskPattern = "\\W"         // Match a non-word character
                            case "a":
                                maskPattern = "[a-zA-Z]"    // Match alphabet
                                default: ()
                        }

                    }
                    
                    if findMatches(inString: String(newChar), usingPattern: maskPattern).count == 0 {
                        
                        processNextChar = true
                        
                    } else {
                        
                        processNextChar = false
                        
                        _maskText = _maskText.stringByReplacingOccurrencesOfString(".", withString: String(newChar), options: .RegularExpressionSearch, range: Range(start:  caretPosition, end: caretPosition + 1))
                        
                        /* Update charachter state */
                        
                        
                        updateChar(caretPosition - blockRangeStart, inBlock: block, toState: true)
                        
                        /* Update Replaced chars and Carret counter */
                        
                        charsReplaced++
                        caretPosition++
                    }
                }
            }
            
            /* Save */
            
            self.maskText = _maskText
            
            /* Events */
            
            var event: AKMaskFieldSEvets!
            
            if charsReplaced == charsToReplace && caretPosition == range.startIndex {
                
                if caretPosition == 0 && range.startIndex == 0 {
                    
                    maskFieldEvent = .Delete
                } else {
                    
                    maskFieldEvent = .None
                }
            } else if charsReplaced != 0 && charsToReplace != 0 {
                
                maskFieldEvent = .Replace
            } else if charsReplaced == 0  {
                
                if caretPosition != range.startIndex {
                    
                    maskFieldEvent = .Insert
                } else {
                    
                    maskFieldEvent = .Delete
                }
            } else {
                
                maskFieldEvent = .Insert
            }
            
            /* Status */
            
            
            var charsFilled: Int = 0
            
            var charsTotal = 0
            
            for block in maskObject {
                
                for char in block.chars  {
                    if char.status {
                        
                        charsFilled++
                    }
                }
                
                charsTotal += block.range.toNSRange().length
            }
            
            if charsFilled == 0 {
                
                maskFieldStatus = .Clear
                
            } else if charsFilled == charsTotal {
                
                maskFieldStatus = .Complete
                
            } else {
                
                maskFieldStatus = .Incomplete
            }
            
            /* Update Field */
            
            updateMaskField()
            
            /* Move caret to new position if field on focus */
            
            moveCaretToPosition(caretPosition)
            
            /* Send delegate */
            
            maskDelegate?.maskField!(self, shouldChangeCharacters: oldText, InRange: range.toNSRange(), replacementString: newText)
        
            return false
            
        } else {
            
            return true
        }
    }
    
    
    // MARK: - Help Methods
    // -------------------------------------------------------------------------------------------------- //
    
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

    private func updateChar(index: Int, inBlock block: AKMaskFieldBlock, toState state: Bool) {
    
        /* Get Chars */
        
        var chars = block.chars
        
        /* Set Char State */
        
        chars[index].status = state
        
        /* Save Chars */
        
        maskObject[block.index].chars = chars
        
        /* Update Block State */
        
        var charsFilled: Int = 0
        
        for char in chars {
            if char.status {
                
                charsFilled++
            }
        }
        
        maskObject[block.index].status = block.range.toNSRange().length == charsFilled ? true : false
    }
    
    private func resetText(inRange range: Range<Int>) {
        
        if range.toNSRange().length > 0 {
            for index in range {
                
                for block in maskObject {
                    
                    let blockRange = block.range
                    
                    if  index >= blockRange.startIndex && index < blockRange.endIndex {
                        
                        // Set empty char to false
                        updateChar(index - blockRange.startIndex, inBlock: block, toState: false)
                        
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    // -------------------------------------------------------------------------------------------------- //
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        self.maskFieldDidBeginEditing(textField)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return self.maskField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}

