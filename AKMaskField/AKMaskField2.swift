//
//  AKMaskField.swift
//  AKMaskField
//  GitHub: https://github.com/artemkrachulov/AKMaskField
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

// MARK: - Enums
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

enum AKMaskFieldStatus {
    case Clear
    case Incomplete
    case Complete
}
enum AKMaskFieldEvet {
    case None
    case Insert
    case Delete
    case Replace
}

// MARK: - AKMaskFieldDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

@objc protocol AKMaskFieldDelegate {
    optional func maskFieldDidBeginEditing(maskField: AKMaskField)
    optional func maskField(maskField: AKMaskField, shouldChangeCharacters oldString: String, inRange range: NSRange, replacementString withString: String)
}

// MARK: - AKMaskField
// --------------------------------------------------------------------------------------------------- //
class AKMaskField: UITextField {
	
	deinit {
		removeObserver(self, forKeyPath: "text")
    print("deinit \(self.dynamicType)")
	}
	
  
  override func removeFromSuperview() {
    super.removeFromSuperview()
    
//    removeObserver(self, forKeyPath: "text")
  }
    
    // MARK: - Displaying mask
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    @IBInspectable var mask: String {
        get { return _mask }
        set {
            
            // Save value
            _mask = newValue
            
            if !_mask.isEmpty {
                
                // Reset mask object
                reset()
                
                maskObject = [AKMaskFieldBlock]()
                
                // Brackets
                let leftBracket = String(maskBlockBrackets[0])
                let rightBracket = String(maskBlockBrackets[1])
                
                // Copy mask and strip left and right bracket
                maskWithoutBrackets = _mask.stringByReplacingOccurrencesOfString("[" + leftBracket + rightBracket + "}]", withString: "", options: .RegularExpressionSearch, range: nil)
                
                let blocks = findMatches(inString: newValue, usingPattern: "(?<=\\" + leftBracket + ").*?(?=\\" + rightBracket + ")")
                
                if blocks.count > 0 {
                    for (i, block) in blocks.enumerate() {
                        
                        let range = (block.range as NSRange).toRange()!
                        
                        let multiplier = (i * 2) + 1
                        
                        let bRange = range.startIndex - multiplier..<range.endIndex - multiplier
                        
                        // Process block characters
                        var chars = [AKMaskFieldBlockChars]()
                        
                        for (y, index) in bRange.enumerate() {
                            
                            chars.append(AKMaskFieldBlockChars(index: y, status: false, text: maskTemplateDefaultChar, range: index..<index+1))
                        }
                        
                        // Process blocks
                      
                      let nRange = RangeIntToRangeStringIndex(_mask, range: range)
                      
                        maskObject.append(AKMaskFieldBlock(index: i, status: false, range: bRange, mask: _mask.substringWithRange(nRange), text: "", template: "", chars: chars))
                    }
                    
                    // Set Placeholder
                    maskTemplate = _maskTemplate ?? String(maskTemplateDefaultChar)
                }
            }
        }
    }
    
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
                
                if _maskTemplate.characters.count == maskWithoutBrackets.characters.count {
                    copy = false
                } else {
                    if _maskTemplate.characters.count == 1 {
                        copyChar = _maskTemplate
                    }
                }
                
                for (i, block) in maskObject.enumerate() {
                    
                    let range = block.range
                    
                    // Prepare template
                    var template = ""
                    if copy {
                        for _ in range {
                            template += copyChar
                        }
                    } else  {
                      let nRange = RangeIntToRangeStringIndex(_maskTemplate, range: range)
                        template = _maskTemplate.substringWithRange(nRange)
                    }
                    
                    // Save changes to value
                  
                   maskTemplateText = replaceOccurrencesOfString("(.+)", withString: template, inString: maskTemplateText, options: .RegularExpressionSearch, aRange: range)
                    
                    // Replace character to new template character
                    var chars = maskObject[i].chars
                    for (y, char) in template.characters.enumerate() {
                        
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
                maskObjectClean = maskObject
                
                // Set new text
                textField(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text!)
            }
        }
    }
  
  func replaceOccurrencesOfString(target: String, withString: String, inString: String, options: NSStringCompareOptions, aRange: Range<Int>!) -> String {
    
    let range = aRange == nil ? nil : RangeIntToRangeStringIndex(inString, range: aRange) as Range<String.Index>!
    
    
    return inString.stringByReplacingOccurrencesOfString(target, withString: withString, options: options, range: range)
  }
  
  /*
    public func stringByReplacingOccurrencesOfString(target: String, withString: String, options: NSStringCompareOptions, aRange: Range<Int>!) -> String {
      
      let range = aRange == nil ? nil : converRangeIntToRangeStringIndex(self, range: aRange) as Range<String.Index>!
      
      return stringByReplacingOccurrencesOfString(target, withString: withString, options: options, range: range)
    }*/
  
  
    // MARK: - Configuring mask
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    var maskBlockBrackets: [Character] = ["{", "}"]
    
    // MARK: - Mask object
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    private(set) var maskObject: [AKMaskFieldBlock]!
    
    // MARK: - Status of the mask and an user events
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    private(set) var maskStatus: AKMaskFieldStatus = .Clear
    private(set) var maskEvent: AKMaskFieldEvet = .None

    // MARK: - Accessing the Delegate
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    weak var maskDelegate: AKMaskFieldDelegate?

    // Flags
    private var flagUpdateEvent: Bool!

    // Saved properties
    private var _mask: String!
    private var _maskShowTemplate  = false
    private var _maskTemplate: String!
    
    private(set) var maskWithoutBrackets: String!
    private var maskTemplateDefaultChar: Character = "*"
    private(set) var maskTemplateText: String!
    
    private(set) var maskText: String!
    
    private var maskObjectClean: [AKMaskFieldBlock]!
    
    // MARK: - Draw
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Apply the delegate
        delegate = self
        
        // This observer used on manual updatind text property
			
        addObserver(self, forKeyPath: "text", options: [], context: nil)
			
    }
    
    func refresh() {

        if maskObject.count > 0 && maskText != text {
            text = maskShowTemplate ? maskText : maskStatus == .Clear ? "" : maskText
        }
        
        // Reset manual updating property flag
        flagUpdateEvent = true
    }
    
    func reset() {
        maskObject = nil
        text = ""
    }
    
    // MARK: - Helper Methods
    //         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    
    private func updateBlock(block: AKMaskFieldBlock, character: Character!, atIndex index: Int) {
        
        // Copy
        var chars = block.chars
        var text = block.text
        
        // Check char
        let isChar = character != nil
        
        // Switch to mask char if nil
      
        let nRange = RangeIntToRangeStringIndex(block.template, range: index..<index+1)
      
        let newChar = isChar ? String(character) : block.template.substringWithRange(nRange)
      
      

      
        text.replaceRange(RangeIntToRangeStringIndex(text, range: index..<index+1), with: newChar)
        
        // Save
        chars[index].text = Character(newChar)
        chars[index].status = isChar
        
        // Update Block Status
        var charsFilled: Int = 0
        for char in chars {
            if char.status {
                
                charsFilled += 1
            }
        }
        
        maskObject[block.index].status = block.range.toNSRange().length == charsFilled
        maskObject[block.index].text = text
        maskObject[block.index].chars = chars
    }
    
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
        for char: Character in bStr.characters {
            
            // Break from loop if pasted lenght go out mask
            if position >= aStr.characters.count || (charsToReplace > 0 && charsToReplace == charsReplaced) { break }
            
            // Ignore this if we process new char
            if !flagNextChar {
                oldChar = aStr[aStr.startIndex.advancedBy(position)]
            }
            
            // Get block with caret
            let (active, block) = activeBlock(position)
            
            let startPosition = block.range.startIndex
            
            if oldChar == char && !active {
                
                position += 1
            } else {
                
                // Ignore this if we process new char
                if !flagNextChar {
                    
                    // Set position to block start index
                    position = max(position, startPosition)
                    
                    // Check char with pattern
                  
                    let nRange = RangeIntToRangeStringIndex(maskWithoutBrackets, range: position...position)
                  
                    switch maskWithoutBrackets.substringWithRange(nRange) {
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
                  
                  
                  aStr = replaceOccurrencesOfString(".", withString: String(char), inString: aStr, options: .RegularExpressionSearch, aRange: position...position + 1)
                    
                    // Update charachter state
                    updateBlock(block, character: char, atIndex: position - startPosition)
                    
                    // Update ounters
                    charsReplaced += 1
                    position += 1
                }
            }
        }
        return (position, charsToReplace, charsReplaced)
    }
    
    private func activeBlock(caret: Int) -> (active: Bool, block: AKMaskFieldBlock) {
        
        var _block: AKMaskFieldBlock!
        var active: Bool!
        
        for (_, block) in maskObject.enumerate() {
            
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
        
//        var error: NSError?
        let expression = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        let matches = expression.matchesInString(string, options: [], range: NSMakeRange(0, string.characters.count))
        
        return matches
    }
    
    private func moveCaretToPosition(position: Int) {
    
        if let beginningOfDocument: UITextPosition = beginningOfDocument {
            
            let caretPosition = positionFromPosition(beginningOfDocument, offset: position)
            selectedTextRange  = textRangeFromPosition(caretPosition!, toPosition: caretPosition!)
        }
    }
}

// MARK: - Observers
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKMaskField {

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if (keyPath == "text" && object === self && flagUpdateEvent == true) {
            
            // Reset data on manual updating
            maskText = maskTemplateText
            maskObject = maskObjectClean
            
            // Process field
            textField(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text!)
        }
    }
}

// MARK: - UITextFieldDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKMaskField: UITextFieldDelegate {

    func textFieldDidBeginEditing(textField: UITextField) {
        if maskObject.count > 0 {
            
            var position = 0
            
            switch maskStatus {
            case .Complete:
                
                position = maskTemplateText.characters.count
                
            case .Incomplete:
                
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
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Set flags
        flagUpdateEvent = false
        
        // Change chars
        if maskObject.count > 0 {
            
            let range = range.toRange()!
            
            // Copy
            var _maskText = maskText as String
          
            let nRange = RangeIntToRangeStringIndex(_mask, range: range)
          
            let charactersToChange = _maskText.substringWithRange(nRange)
            
            // Step 1
            // Replace current string with template string
//            _maskText = _maskText.stringByReplacingOccurrencesOfString(".+", withString: maskTemplateText.subStringWithRange(range), options: .RegularExpressionSearch, aRange: range)
          
          let nRange2 = RangeIntToRangeStringIndex(maskTemplateText, range: range)
          
          _maskText = replaceOccurrencesOfString(".+", withString: maskTemplateText.substringWithRange(nRange2), inString: _maskText, options: .RegularExpressionSearch, aRange: range)
          
          
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
            
//            var event: AKMaskFieldEvet!
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
                        filled += 1
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
            
        } else { return true }
    }
	

	
}