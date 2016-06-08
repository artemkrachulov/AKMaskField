//
//  AKMaskField.swift
//  AKMaskField
//  GitHub: https://github.com/artemkrachulov/AKMaskField
//
//  Created by Artem Krachulov
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

import UIKit

class AKMaskField: UITextField {

  //  MARK: - Set up mask
  
  /// The string value that contains blocks with symbols that determines certain format of input data. 
  /// Each block must be wrapped in brackets. Default brackets is { ... }.
  ///
  /// The predetermined formats (Mask symbol : Input format):
  ///
  ///     d	: Number, decimal number from 0 to 9
  ///     D	: Any symbol, except decimal number
  ///     W	: Not an alphabetic symbol
  ///     a	: Alphabetic symbol, a-Z
  ///     .	: Corresponds to any symbol (default)
  ///
  /// This string is empty by default.
  @IBInspectable var mask: String? = "" {
    didSet {
      if let mask = mask where !mask.isEmpty {
        
        initialize()
        reset()
        
        // Find brackets blocks
        let bracketBlocks = matchesInString(mask,
                                            regularExpressionPattern: "(?<=\\" + blockBrackets.sLeft + ").*?(?=\\" + blockBrackets.sRight + ")")
        
        if bracketBlocks.isEmpty {
          // In brackets not found, example if mask property
          // was set not one time, class will destroy
          destroy()
        } else {
          // Strip brackets
          maskWithoutBrackets = mask.stringByReplacingOccurrencesOfString("[" + blockBrackets.sLeft + blockBrackets.sRight + "]",
                                                                          withString: "",
                                                                          options: .RegularExpressionSearch,
                                                                          range: nil)
          
          // and save as default placeholder
          // to process this string with template
          templatePlaceholder = maskWithoutBrackets
          
          // Prepare mask template
          let template = _template()
          
          // Prepare empty block container
          maskObject = [AKMaskFieldBlock]()
          
          for (blockId, block) in bracketBlocks.enumerate() {
            
            let range = block.range.toRange()!
            let multiplier = (blockId * 2) + 1
            let blockCharsRange = range.startIndex - multiplier..<range.endIndex - multiplier
            
            // Characters
            var blockCharacters = [AKMaskFieldBlockChars]()
            
            for (characterId, characterRangeIndex) in blockCharsRange.enumerate() {
              blockCharacters.append(
                AKMaskFieldBlockChars(index: characterId+1,
                  status: false,
                  range: characterRangeIndex..<characterRangeIndex+1,
                  text: nil)
              )
            }
            
            // Block
            maskObject!.append(
              AKMaskFieldBlock(index: blockId+1,
                status: false,
                range: blockCharsRange,
                mask: mask.substringWithRange(rangeIntToRangeStringIndex(mask, range: range)!),
                template: blockTemplate(template, inRange: blockCharsRange),
                chars: blockCharacters)
            )
          }
          
          // Save object if in future user will clear mask field
          maskObjectSaved = maskObject
          
          // Save new mask text
          maskText = templatePlaceholder
        }
        
        // Update mask text if storyboard field has text proterty
        textFieldDelegateBlocked(shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text ?? "")
        
      } else {
        destroy()
      }
    }
  }
  
  /// The string that represents the mask field with replacing format symbol with template characters.
  /// 
  /// Can be set (characters count):
  ///   
  ///     1	This character will be copied in each block and will replace mask format symbol.
  ///     Same length as mask without brackets	Template character will replace mask format symbol in same position.
  ///
  /// The initial value of this property is *
  @IBInspectable var maskTemplate: String! = "*" {
    didSet {
      
      guard maskObject != nil else { return }

      // Prepare mask template
      let template = _template()
      
      // Process object
      for (blockId, block) in maskObject!.enumerate() {
        maskObject![blockId].template = blockTemplate(template, inRange: block.range)
      }
      
      // Save / reset old mask text with new
      // templatePlaceholder property was opdated when
      // we processed object before
      maskText = templatePlaceholder
      
      // Resfesh mask text with completed charachters
      updateWithObject()
    }
  }
  
  //  MARK: - Configuring mask
  
  /// Two characters (opening and closing bracket for the block mask).
  ///
  /// The initial values is { and }.
  var blockBrackets = AKMaskFieldBrackets(left: "{", right: "}")
  
  //  MARK: -  Accessing the Delegate
  
  /// A mask field delegate responds to editing-related messages from the mask field.
  weak var maskDelegate: AKMaskFieldDelegate?
  
  //  MARK: - Properties
  
  /// An array with all mask blocks
  private(set) var maskObject: [AKMaskFieldBlock]?
  
  /// Current status of the mask field.
  private(set) var maskStatus: AKMaskFieldStatus = .Clear
  
  //  MARK:   Private props
  
  /// Mask with stripped brackets.
  /// Used as source for finding mask character and comparing with new character
  private var maskWithoutBrackets: String!
  
  /// Duplication mask object after creation. Will replace current object after clearing field.
  private var maskObjectSaved: [AKMaskFieldBlock]?
  
  /// Default mask tempate character
  private var templateDefaultChar: Character = "*"

  /// String for processing mask text
  private var maskText: String = ""
  
  /// Mask template placeholder which will placed in mask after initialization .
  private var templatePlaceholder: String = ""
  
  //  MARK:   Flags
  
  /// Detects if observers was added. Prevent adding multiple observers.
  private var observerAdded: Bool = false
  
  /// Block observer when needs change text property
  private var blockobserver: Bool = false
  
/// Block delegate when not user change text property
  private var blockDelegate: Bool = false
  
  //  MARK: - Methods
  
  func setMask(mask: String, withMaskTemplate maskTemplate: String!) {
    self.mask = mask
    self.maskTemplate = maskTemplate ?? String(templateDefaultChar)
  }
  
  //  MARK: - Life cycle
  
  deinit { destroy() }
  
  //  MARK: - Private
  
  /// Initialize with  delegate and oservers:
  ///   - text
  ///   - placeholder
  private func initialize() {
    guard !observerAdded else { return }
    
    delegate = self
    
    addObserver(self, forKeyPath: "text", options: [], context: nil)
    addObserver(self, forKeyPath: "placeholder", options: [], context: nil)
    observerAdded = !observerAdded
  }
  
  private func destroy() {
    guard observerAdded else { return }
    
    delegate = nil
    
    removeObserver(self, forKeyPath: "text")
    removeObserver(self, forKeyPath: "placeholder")
    observerAdded = !observerAdded
    
    mask = ""
    text = nil
    maskObject = nil
    maskObjectSaved = nil
  }
  
  //  MARK: - Obsever
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard !blockobserver else { return }
    
    switch keyPath! {
    case "text":
      maskObject = maskObjectSaved
      maskStatus = .Clear
      maskText = templatePlaceholder
      
      textField(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text ?? "")
    case "placeholder" :
      updateWithObject()
    default: ()
    }
  }

  //  MARK: - Private methods

  /// Checking if current mask template valid for replacing in same range as mask block. 
  /// And what character we can use for copying in other case.
  ///
  private func _template() -> (copy: Bool, character: String) {
    
    let copy = maskTemplate.characters.count != maskWithoutBrackets.characters.count
    
    var templateCharacter = String(templateDefaultChar)
    
    if copy {
      if maskTemplate.characters.count == 1 {
        templateCharacter = maskTemplate
      }
    } else {
      templateCharacter = maskTemplate
    }
   
    return (copy, templateCharacter)
  }

  private func blockTemplate(_template: (copy: Bool, character: String), inRange range: Range<Int>) -> String {
    
    var blockTemplate = ""
    if _template.copy {
      for _ in range {
        blockTemplate += _template.character
      }
    } else  {
      blockTemplate = maskTemplate.substringWithRange(rangeIntToRangeStringIndex(maskTemplate, range: range)!)
    }
    
    // Update placeholder with new template block
    templatePlaceholder = templatePlaceholder.stringByReplacingOccurrencesOfString("(.+)",
                                                                                  withString: blockTemplate,
                                                                                  options: .RegularExpressionSearch,
                                                                                  range: rangeIntToRangeStringIndex(templatePlaceholder, range: range))
    
    return blockTemplate
  }
  
  private func updateWithObject() {
    if maskStatus == .Clear {
      textFieldObserverBlockedUpdateString(maskText)
    } else {
      for b in maskObject! {
        for c in b.chars {
          if c.status {
            textFieldDelegateBlocked(shouldChangeCharactersInRange: toNSRange(c.range), replacementString: String(c.text!))
          }
        }
      }
    }
  }
  
  /// Clear mask field with reseting object, staus and mask text
  private func reset() {
    guard maskObject != nil else {return }

    maskObject = maskObjectSaved
    maskStatus = .Clear
    maskText = templatePlaceholder
    
    textFieldObserverBlockedUpdateString(nil, hard: true)
  }
  
  private func textFieldObserverBlockedUpdateString(string: String?, hard: Bool = false) {
    blockobserver = true
    if maskStatus == .Clear || hard {
      if placeholder != nil {
        text = nil
      } else {
        text = templatePlaceholder
      }
    } else {
      text = string
    }
    blockobserver = false
  }
  
  private func textFieldDelegateBlocked(shouldChangeCharactersInRange range: NSRange, replacementString string: String) {    
    blockDelegate = true
    textField(self, shouldChangeCharactersInRange: range, replacementString: string)
    blockDelegate = false
  }
  
  private func updateCharacter(character: Character!, characterIndex: Int, inBlock blockIndex: Int, withStatus status: Bool) {
    maskObject![blockIndex].chars[characterIndex].status = status
    maskObject![blockIndex].chars[characterIndex].text = character
  }
  
  private func replaceCharacter(character: Character, inRange range: Range<Int>, beforeReplace:(() -> Void), afterReplace: (() -> Void)) {
    
    let maskCharacter = maskWithoutBrackets.substringWithRange(rangeIntToRangeStringIndex(maskWithoutBrackets, range: range.startIndex...range.startIndex)!)
    
    var pattern = "."
    switch maskCharacter {
    case "d": pattern = "\\d"         // Number, Decimal Digit
    case "D": pattern = "\\D"         // Match any character that is not a decimal digit
    case "W": pattern = "\\W"         // Match a non-word character
    case "a": pattern = "[a-zA-Z]"    // Match alphabet
    default: ()
    }
    
    if !matchesInString(String(character), regularExpressionPattern: pattern).isEmpty {
      beforeReplace()
      maskText = maskText.stringByReplacingOccurrencesOfString(".",
                                                               withString: String(character),
                                                               options: .RegularExpressionSearch,
                                                               range: rangeIntToRangeStringIndex(maskText, range: range.startIndex...range.startIndex))
      
      afterReplace()
    }
  }
  
  private func resetString(withString string: String, inRange range: Range<Int>) {
    
    maskText.replaceRange(rangeIntToRangeStringIndex(maskText, range: range)!, with: string)
    
    for ind in range {
      for (blockIndex, block) in self.maskObject!.enumerate() {
        if block.range ~= ind {
          let charId = ind - block.range.startIndex
          updateCharacter(nil, characterIndex: charId, inBlock: blockIndex, withStatus: false)
          break
        }
      }
    }
  }
  
  private func debugMaskObject() {
    guard maskObject != nil else {
      return
    }
    
    for b in maskObject! {
      print("index \(b.index)")
      print("status \(b.status)")
      print("mask \(b.mask)")
      
      print("template \(b.template)")
      print("range \(b.range)")
      print("   ----  ")
      for c in b.chars {
        print("   index \(c.index)")
        print("   status \(c.status)")
        print("   range \(c.range)")
        print("   ----  ")
      }
      print(" ")
    }
  }
  
  private func matchesInString(string: String, regularExpressionPattern pattern: String) -> [NSTextCheckingResult] {
    let expression = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    return expression.matchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, string.characters.count))
  }
  
  private func moveCaretToPosition(position: Int) {
    if let beginningOfDocument: UITextPosition = beginningOfDocument {
      let caretPosition = positionFromPosition(beginningOfDocument, offset: position)
      selectedTextRange  = textRangeFromPosition(caretPosition!, toPosition: caretPosition!)
    }
  }
  
  private func toNSRange(range: Range<Int>) -> NSRange {
    let loc = range.startIndex
    let len = range.endIndex - loc
    return NSMakeRange(loc, len)
  }
  
  private func rangeIntToRangeStringIndex(str: String, range: Range<Int>) -> Range<String.Index>? {
    guard range.startIndex <= str.characters.count && range.endIndex <= str.characters.count else {
      return nil
    }
    return Range<String.Index>(str.startIndex.advancedBy(range.startIndex)..<str.startIndex.advancedBy(range.endIndex))
  }  
}

// MARK: - UITextFieldDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension AKMaskField: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(textField: UITextField) {
    
    guard let maskObject = maskObject where !maskObject.isEmpty else {
      return
    }
    
    var position = 0
    
    switch maskStatus {
      case .Clear:
      
      textFieldObserverBlockedUpdateString(templatePlaceholder)
      position = (maskObject.first as AKMaskFieldBlock!).range.startIndex
      
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
      case .Complete:
      position = maskText.characters.count
    }
    
    moveCaretToPosition(position)
    
    //  Delegate
    //
    maskDelegate?.maskFieldDidBeginEditing(self)
  }

  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    guard let maskObject = maskObject where !maskObject.isEmpty else {
      return true
    }
    
  
    
    let rangeInt = range.toRange()!
    
    var resetBeforeInsert = false
    var cuttedtemplatePlaceholder: String!
    
    // Initial carret position
    var caret = range.location
    
    if range.length != 0 {

        cuttedtemplatePlaceholder = templatePlaceholder.substringWithRange(rangeIntToRangeStringIndex(templatePlaceholder, range: rangeInt)!)
      
        if string.isEmpty {
        
          resetString(withString: cuttedtemplatePlaceholder, inRange: rangeInt)
 
          if caret < self.maskObject?.first?.range.startIndex {
            caret = (self.maskObject?.first?.range.startIndex)!
            
            textFieldObserverBlockedUpdateString(maskText)
            moveCaretToPosition(caret)
            
            maskStatus = .Clear
            
            if !blockDelegate {
              maskDelegate?.maskField(self, didChangeCharactersInRange: range, replacementString: string, withEvent: .Delete)
            }

            return false
          }

          for (blockIndex, block) in maskObject.enumerate() {
            if blockIndex != 0 {
              if self.maskObject![blockIndex-1].range.endIndex ... block.range.startIndex ~= caret {
                caret = self.maskObject![blockIndex-1].range.endIndex
                break
              }
            }
          }
        } else {
          resetBeforeInsert = true
      }
    }
    
    

    if !string.isEmpty {
      for character in string.characters {
        if (range.length != 0 && caret >= rangeInt.endIndex) || caret >= maskText.characters.count { break }
        
        for (blockIndex, block) in maskObject.enumerate() {
          
          let blockRange = block.range
          
          if caret >= blockRange.startIndex && caret < blockRange.endIndex {
            replaceCharacter(character,
                             inRange: caret...caret,
                             beforeReplace: {
                              if resetBeforeInsert {
                                self.resetString(withString: cuttedtemplatePlaceholder, inRange: rangeInt)
                                resetBeforeInsert = false
                              }
              },
                             afterReplace: {
                              self.updateCharacter(character, characterIndex: caret - blockRange.startIndex, inBlock: blockIndex, withStatus: true)
                              caret += 1
            })
            break
          } else {

            let maskCharacter = Character(maskText.substringWithRange(rangeIntToRangeStringIndex(maskText, range: caret...caret)!))
            
            if maskCharacter == character {
              caret += 1
              break
            } else {
              if caret <= blockRange.startIndex {
                
                replaceCharacter(character,
                                 inRange: blockRange,
                                 beforeReplace: {
                                  if resetBeforeInsert {
                                    self.resetString(withString: cuttedtemplatePlaceholder, inRange: rangeInt)
                                    resetBeforeInsert = false
                                  }
                  },
                                 afterReplace: {
                                  caret = blockRange.startIndex
                                  self.updateCharacter(character, characterIndex: 0, inBlock: blockIndex, withStatus: true)
                                  caret += 1
                                  
                })
               
                break
              }
            }
          }
        }
      }
    }
  
    //  Events

    var event: AKMaskFieldEvent = .Error
    if rangeInt.startIndex < caret {
      if range.length != 0 {
        event = .Replace
      } else {
        event = .Insert
      }
    } else if rangeInt.endIndex > caret {
      event = .Delete
    } else if range.length == 0 && string.isEmpty {
      event = .Delete
    }
    
    //  Save mask status
   
    var total = 0
    
    maskStatus = .Clear
    
    for (blockIndex, block) in self.maskObject!.enumerate() {
      var filled = 0
      
      for char in block.chars  {
        if char.status {
          filled += 1

          maskStatus = .Incomplete
        }
      }
      
      if block.chars.count == filled {
        self.maskObject![blockIndex].status = true
        total += 1
      } else {
        self.maskObject![blockIndex].status = false
      }
    }
    
    if maskObject.count == total {
      maskStatus = .Complete
    }
    
    textFieldObserverBlockedUpdateString(maskText)
    
    if !blockDelegate {
      moveCaretToPosition(caret)
      maskDelegate?.maskField(self, didChangeCharactersInRange: range, replacementString: string, withEvent: event)
    }
    
    return false
  }
}

//  MARK: - AKMaskFieldDelegate

protocol AKMaskFieldDelegate : class  {
  
  /// Tells the delegate that editing began for the specified mask field.
  func maskFieldDidBeginEditing(maskField: AKMaskField)
  
  /// Tells the delegate that specified mask field change text with event.
  func maskField(maskField: AKMaskField, didChangeCharactersInRange range: NSRange, replacementString string: String, withEvent event: AKMaskFieldEvent)
}

extension AKMaskFieldDelegate {
  func maskFieldDidBeginEditing(maskField: AKMaskField) {}
  func maskField(maskField: AKMaskField, didChangeCharactersInRange range: NSRange, replacementString string: String, withEvent event: AKMaskFieldEvent) {}
}