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
//
// v. 0.1
//

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
        
        // Find brackets blocks
        let bracketBlocks = AKMaskFieldUtility.matchesInString(mask,
                                            usingPattern: "(?<=\\" + blockBrackets.sLeft + ").*?(?=\\" + blockBrackets.sRight + ")")
        
        if bracketBlocks.isEmpty {
          // In brackets not found, example if mask property
          // was set not one time, class will destroy
          destroy()
        } else {
          // Strip brackets
          maskWithoutBrackets = AKMaskFieldUtility.replaceOccurrencesInString(mask,
                                                                            usingPattern: "[" + blockBrackets.sLeft + blockBrackets.sRight + "]",
                                                                            withString: "",
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
                mask: AKMaskFieldUtility.substringString(mask, withRange: range),
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
        blockDelegate = true
        textField(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text ?? "")
        blockDelegate = false
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
      updateMaskTextWithObject()
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
  
  //  MARK: Private props

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
  
  //  MARK: Flags
  
  /// Detects if observers was added. Prevent adding multiple observers.
  private var observerAdded: Bool = false
  
  /// Block observer when needs change text property
  private var blockobserver: Bool = false
  
  /// Block delegate when not user change text property
  private var blockDelegate: Bool = false

  /// Check if this mask field become first responder
  private (set) var isBecomeFirstResponder: Bool = false
  
  //  MARK: - Methods
  
  func setMask(mask: String, withMaskTemplate maskTemplate: String!) {
    self.mask = mask
    self.maskTemplate = maskTemplate ?? String(templateDefaultChar)
  }
  
  //  MARK: - Life cycle
  
  /// Initialize with  delegate and oservers:
  ///   - text
  ///   - placeholder
  private func initialize() {
    guard !observerAdded else { return }
    
    delegate = self
    
    addObserver(self, forKeyPath: "placeholder", options: [.New,.Old], context: nil)
    observerAdded = !observerAdded
    
    reset()
  }
  
  private func destroy() {
    guard observerAdded else { return }
    
    delegate = nil
  
    removeObserver(self, forKeyPath: "placeholder")
    observerAdded = !observerAdded
    
    reset()
  }
  
  /// Clear mask field with reseting object, staus and mask text
  private func reset() {
    guard maskObject != nil else { return }
    
    maskObject = maskObjectSaved
    maskStatus = .Clear
    maskText = templatePlaceholder
    
    text = nil
  }
  
  deinit { destroy() }
  
  /// text property
  func updateText(text: String?) {
    guard maskObject != nil else { return }
    
    maskObject = maskObjectSaved
    maskStatus = .Clear
    maskText = templatePlaceholder
    textField(self, shouldChangeCharactersInRange: NSMakeRange(0, 0), replacementString: text ?? "")
  }
  
  //  MARK: - Obsever
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard !blockobserver else { return }
    
    switch keyPath! {
    case "placeholder":
      updateMaskTextWithObject()
    default: ()
    }
  }

  //  MARK: - Private methods

  /// Checking if current mask template valid for replacing in same range as mask block.
  /// And what character we can use for copying in other case.
  private func _template() -> (copy: Bool, character: String) {
    
    let copy = maskTemplate.characters.count != maskWithoutBrackets.characters.count
    var templateCharacter: String!
    
    if copy {
      templateCharacter = maskTemplate.characters.count == 1 ? maskTemplate : String(templateDefaultChar)
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
      blockTemplate = AKMaskFieldUtility.substringString(maskTemplate, withRange: range)
    }
    
    // Update placeholder with new template block
    templatePlaceholder = AKMaskFieldUtility.replaceOccurrencesInString(templatePlaceholder,
                                                                      usingPattern: "(.+)",
                                                                      withString: blockTemplate,
                                                                      range: range)    
    return blockTemplate
  }
  
  /// Updating text in field
  func updateMaskTexWithString(string: String?) {    
    if maskStatus == .Clear {
      if placeholder != nil && !isBecomeFirstResponder {
        text = nil
      } else {
        text = templatePlaceholder
      }
    } else {
      text = string
    }
  }
  
  /// Updating text in field with filled charachters
  private func updateMaskTextWithObject() {
    if maskStatus == .Clear {
      updateMaskTexWithString(maskText)
    } else {
      for b in maskObject! {
        for c in b.chars {
          if c.status {
            blockDelegate = true
            textField(self, shouldChangeCharactersInRange: AKMaskFieldUtility.toNSRange(c.range), replacementString: String(c.text!))
            blockDelegate = false
          }
        }
      }
    }
  }
  
  private func updateCharacter(character: Character!, characterIndex: Int, inBlock blockIndex: Int, withStatus status: Bool) {
    maskObject![blockIndex].chars[characterIndex].status = status
    maskObject![blockIndex].chars[characterIndex].text = character
  }
  
  private func replaceCharacter(character: Character, inRange range: Range<Int>, beforeReplace:(() -> Void), afterReplace: (() -> Void)) {
    
    let maskCharacter = AKMaskFieldUtility.substringString(maskWithoutBrackets,
                                                         withRange: range.startIndex...range.startIndex)
    let sCharacter = String(character)
    
    var pattern = "."
    switch maskCharacter {
    case "d": pattern = "\\d"         // Number, Decimal Digit
    case "D": pattern = "\\D"         // Match any character that is not a decimal digit
    case "W": pattern = "\\W"         // Match a non-word character
    case "a": pattern = "[a-zA-Z]"    // Match alphabet
    default: ()
    }
    
    if !AKMaskFieldUtility.matchesInString(sCharacter,
                                         usingPattern: pattern).isEmpty {
      beforeReplace()
      maskText = AKMaskFieldUtility.replaceOccurrencesInString(maskText,
                                                             usingPattern: ".",
                                                             withString: sCharacter,
                                                             range: range.startIndex...range.startIndex)
      afterReplace()
    }
  }
  
  /// Reset mask text and corresponding characters in object
  private func resetMaskText(withString string: String, inRange range: Range<Int>) {
    
    maskText.replaceRange(AKMaskFieldUtility.rangeIntToRangeStringIndex(maskText, range: range)!,
                          with: string)
    
    for rangeIndex in range {
      for (blockIndex, block) in maskObject!.enumerate() {
        if block.range ~= rangeIndex {
          updateCharacter(nil,
                          characterIndex: rangeIndex - block.range.startIndex,
                          inBlock: blockIndex,
                          withStatus: false)
          break
        }
      }
    }
  }
  
  private func getStatus() -> AKMaskFieldStatus {
    var total = 0
    var status: AKMaskFieldStatus = .Clear
    
    for (blockIndex, block) in maskObject!.enumerate() {
      var filled = 0
      
      for char in block.chars  {
        if char.status {
          filled += 1
          status = .Incomplete
        }
      }
      
      if block.chars.count == filled {
        self.maskObject![blockIndex].status = true
        total += 1
      } else {
        self.maskObject![blockIndex].status = false
      }
    }
    
    if maskObject!.count == total {
      status = .Complete
    }
    
    return status
  }
  
  private func debugMaskObject() {
    guard maskObject != nil else { return }
    
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
}

//  MARK: - UITextFieldDelegate

extension AKMaskField: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(textField: UITextField) {
    guard let maskObject = maskObject where !maskObject.isEmpty else { return }
    
    // Initial carret position
    var position = 0
    
    switch maskStatus {
      case .Clear:
        
      text = templatePlaceholder

      // Get first block start position
      position = maskObject.first!.range.startIndex
      
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
    selectedTextRange = AKMaskFieldUtility.moveCaretToPosition(position, inField: self)
    
    isBecomeFirstResponder = true
    maskDelegate?.maskFieldDidBeginEditing(self)
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    isBecomeFirstResponder = false
    updateMaskTexWithString(maskText)
    
    maskDelegate?.maskFieldDidEndEditing(self)
  }

  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    guard let maskObject = maskObject where !maskObject.isEmpty else { return true }
    
    let rangeInt = range.toRange()!
    var resetBeforeReplace = false
    var cuttedTemplatePlaceholder: String!
    // Initial carret position
    var caret = range.location
    
    if range.length != 0 {

      cuttedTemplatePlaceholder = AKMaskFieldUtility.substringString(templatePlaceholder,
                                                                   withRange: rangeInt)
      
      if string.isEmpty {
        resetMaskText(withString: cuttedTemplatePlaceholder,
                      inRange: rangeInt)
        
        let firstBlockCaret = self.maskObject!.first!.range.startIndex
        
        if caret < firstBlockCaret {
        
          maskStatus = .Clear
          
          updateMaskTexWithString(maskText)
          
          if !blockDelegate {
            selectedTextRange = AKMaskFieldUtility.moveCaretToPosition(firstBlockCaret, inField: self)
            maskDelegate?.maskField(self,
                                    didChangeCharactersInRange: range,
                                    replacementString: string,
                                    withEvent: .Delete)
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
        resetBeforeReplace = true
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
                              if resetBeforeReplace {
                                self.resetMaskText(withString: cuttedTemplatePlaceholder, inRange: rangeInt)
                                resetBeforeReplace = false
                              }
              },
                             afterReplace: {
                              self.updateCharacter(character, characterIndex: caret - blockRange.startIndex, inBlock: blockIndex, withStatus: true)
                              caret += 1
            })
            break
          } else {
            
            if Character(AKMaskFieldUtility.substringString(maskText, withRange: caret...caret)) == character {
              caret += 1
              break
            } else {
              if caret <= blockRange.startIndex {
                replaceCharacter(character,
                                 inRange: blockRange,
                                 beforeReplace: {
                                  if resetBeforeReplace {
                                    self.resetMaskText(withString: cuttedTemplatePlaceholder, inRange: rangeInt)
                                    resetBeforeReplace = false
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
  
    maskStatus = getStatus()
    
    updateMaskTexWithString(maskText)
    
    if !blockDelegate {
      
      let firstBlockCaret = self.maskObject!.first!.range.startIndex
      if caret < firstBlockCaret {
        caret = firstBlockCaret
      }
      
      selectedTextRange = AKMaskFieldUtility.moveCaretToPosition(caret, inField: self)
      
      // Get current event
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
      
      maskDelegate?.maskField(self,
                              didChangeCharactersInRange: range,
                              replacementString: string,
                              withEvent: event)
    }
    return false
  }
}

//  MARK: - AKMaskFieldDelegate

protocol AKMaskFieldDelegate : class  {
  
  /// Tells the delegate that editing began for the specified mask field.
  func maskFieldDidBeginEditing(maskField: AKMaskField)
  
  /// Tells the delegate that editing finished for the specified mask field.
  func maskFieldDidEndEditing(maskField: AKMaskField)
  
  /// Tells the delegate that specified mask field change text with event.
  func maskField(maskField: AKMaskField, didChangeCharactersInRange range: NSRange, replacementString string: String, withEvent event: AKMaskFieldEvent)
}

extension AKMaskFieldDelegate {
  
  func maskFieldDidBeginEditing(maskField: AKMaskField) {}
  
  func maskFieldDidEndEditing(maskField: AKMaskField) {}
  
  func maskField(maskField: AKMaskField, didChangeCharactersInRange range: NSRange, replacementString string: String, withEvent event: AKMaskFieldEvent) {}
}