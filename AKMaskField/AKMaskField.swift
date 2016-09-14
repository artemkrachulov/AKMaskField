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
// v. 1.0
//

import UIKit

/// AKMaskField is UITextField subclass which allows enter data in the fixed quantity 
/// and in the certain format (credit cards, telephone numbers, dates, etc.). 
/// You only need setup mask and mask template visible for the user.
///
/// Example of usage (programmatically):
///
/// ```
/// var field = AKMaskField()
/// field.setMask("{dddd}-{DDDD}-{WaWa}-{aaaa}", withMaskTemplate: "ABCD-EFGH-IJKL-MNOP")
/// ```
///
/// For more information click here [GitHub](https://github.com/artemkrachulov/AKMaskField)
public class AKMaskField: UITextField {
  
  //  MARK: - Configuring the Mask Field
  
  /// The string value that has blocks with pattern symbols that determine the certain format of input data. Wrap each mask block with proper bracket character.
  ///
  /// The predetermined formats (Mask symbol : Input format):
  ///
  /// - `d`	: Number, decimal number from 0 to 9
  /// - `D`	: Any symbol, except decimal number
  /// - `W`	: Not an alphabetic symbol
  /// - `a`	: Alphabetic symbol, a-Z
  /// - `.`	: Corresponds to any symbol (default)
  ///
  /// Default value of this property is `nil`.
  @IBInspectable final var mask: String? {
    didSet {
      
      // - - - - - - - - - - - -
      // CHECKS
      // - - - - - - - - - - - -
      
      if guardMask { return }
      
      let brackets = AKMaskFieldUtility
        .matchesInString(mask!,
                         pattern: "(?<=\\\(maskBlockBrackets.left)).*?(?=\\\(maskBlockBrackets.right))")
      
      if brackets.isEmpty { return }
      
      // - - - - - - - - - - - -
      // SETUP
      // - - - - - - - - - - - -

      delegate = self
      
      maskTemplateText = mask

      // - - - - - - - - - - - -
      // MASK OBJECT
      // - - - - - - - - - - - -
      
      maskBlocks = [AKMaskFieldBlock]()
      
      for (i, bracket) in brackets.enumerate() {
        
        // - - - - - - - - - - - - - - - -
        // Characters
        
        var characters = [AKMaskFieldBlockCharacter]()
        
        for y in 0..<bracket.range.length {
          
          let patternRange  = NSMakeRange(bracket.range.location + y, 1)
          var templateRange = patternRange
          templateRange.location -=  i * 2 + 1
          
          let pattern = AKMaskFieldPatternCharacter(rawValue: AKMaskFieldUtility.substring(mask, withNSRange: patternRange))
          
          characters.append(AKMaskFieldBlockCharacter(
            index         : y,
            blockIndex    : i,
            status        : .Clear,
            pattern       : pattern,
            patternRange  : patternRange,
            template      : maskTemplateDefault,
            templateRange : templateRange))
        }
        
        // - - - - - - - - - - - - - - - -
        // Blocks
        
        maskBlocks.append(AKMaskFieldBlock(
          index : i,
          chars : characters))
        
        updateMaskTemplateTextFromBlock(i)
      }
      
      // - - - - - - - - - - - -
      // DISPLAYED TEXT
      // - - - - - - - - - - - -
      
      updateMaskTemplateText()
      
      #if AKMaskFieldDEBUG
      debugmaskBlocks()
      #endif
    }
  }
  
  /// Default character for the mask templates initialization.
  private var maskTemplateDefault: Character = "*"
  
  /// The text that represents the mask filed with replacing mask symbol by template character.
  ///
  /// - `1` : Template character will be copied to each mask block with repeating equal block length.
  /// - `Equal` : Template length equal to mask without brackets. Template characters will replace mask blocks in same range.
  /// 
  /// Default value of this property is `*`.
  @IBInspectable final var maskTemplate: String = "*" {
    didSet {
      
      // CHECKS
      
      if guardMask { return }

      maskTemplateText = mask
      
      var copy: Bool = true
      var _maskTemplate = String(maskTemplateDefault)

      if maskTemplate.characters.count == mask!.characters.count - (maskBlocks.count * 2) {
        copy = false
        _maskTemplate = maskTemplate
      } else if maskTemplate.characters.count == 1 {
         _maskTemplate = maskTemplate
      }

      for block in maskBlocks {
        for char in block.chars {
          maskBlocks[char.blockIndex].chars[char.index].template = copy
            ? Character(_maskTemplate)
            : Character(AKMaskFieldUtility.substring(maskTemplate, withNSRange: char.templateRange))
        }
        
        updateMaskTemplateTextFromBlock(block.index)
      }
      
      // - - - - - - - - - - - -
      // DISPLAYED TEXT
      // - - - - - - - - - - - -
      
      updateMaskTemplateText()
    }
  }
  
  /// Use this method to set the mask and template parameters.
  ///
  /// - `mask` : The string value that has blocks with symbols that determine the certain format of input data.
  /// - `maskTemplate` : The text that represents the mask filed with replacing mask symbol by template character.
  public func setMask(mask: String, withMaskTemplate maskTemplate: String!) {
    self.mask         = mask
    self.maskTemplate = maskTemplate ?? String(maskTemplateDefault)
  }
  
  /// Open and close bracket character for the mask block.
  ///
  /// Default value of this property is `{` and `}`.
  final var maskBlockBrackets: AKMaskFieldBrackets = AKMaskFieldBrackets(left: "{", right: "}")
  
  struct AKMaskFieldBrackets {
    let left, right: Character
  }
  
  //  MARK: - Mask Field actions
  
  /// Set new text for the mask field. Equal to select all and paste actions.
  ///
  /// - `text` : The text inserted in the mask field.
  public func setMaskText(text: String?) {
    guard let maskText = maskText else {
      return
    }
    textField(self, shouldChangeCharactersInRange: NSMakeRange(0, maskText.characters.count), replacementString: text ?? "")
  }
  
  /// Manually refresh the mask field
  public func refreshMask() {
    if maskStatus == .Clear {
      if placeholder != nil {
        text = nil
      } else {
        text = maskTemplateText
      }
    } else {
      text = maskText
    }
  }
  
  //  MARK: - Accessing the Delegate
  
  /// The receiver’s delegate.
  public weak var maskDelegate: AKMaskFieldDelegate?
  
  //  MARK: - Getting the Mask Field status
  
  /// Returns the current status of the mask field. The value of the property is a constant. 
  public final var maskStatus: AKMaskFieldStatus {
    
    let maskBlocksChars = maskBlocks.flatMap { $0.chars }
    let completedChars  = maskBlocksChars.filter { $0.status == .Complete }
    
    switch completedChars.count {
    case 0                     : return .Clear
    case maskBlocksChars.count : return .Complete
    default                    : return .Incomplete
    }
  }
  
  //  MARK: - Getting the Mask Field object
  
  /// Returns an array containing all the Mask Field blocks.
  private(set) var maskBlocks: [AKMaskFieldBlock] = [AKMaskFieldBlock]()
  
  //  MARK: - Displayed Properties
  
  private var maskText: String!
  private var maskTemplateText: String!
  
  public override var placeholder: String?  {
    didSet { refreshMask() }
  }
  
  //  MARK: - Life cycle
  
  deinit {
    #if AKMaskFieldDEBUG
      print("\(type(of: self)) \(#function)")
    #endif
  }
  
  //  MARK: - Helper methods & Properties
  
  private var guardMask: Bool {
    guard let mask = mask where !maskBlocks.isEmpty || !mask.isEmpty else {
      return true
    }
    return false
  }
  
  /// Returns next character from target location
  private func getNetCharacter(chars: [AKMaskFieldBlockCharacter], fromLocation location: Int) -> (char: AKMaskFieldBlockCharacter, outsideBlock: Bool) {
    
    var nextBlockIndex: Int!
    
    var range = 0..<chars.count
    while range.startIndex < range.endIndex {
      
      let midIndex = range.startIndex + (range.endIndex - range.startIndex) / 2
      let charLocation = chars[midIndex].templateRange.location
      
      if charLocation == location {
        return (chars[midIndex], false)
      } else if charLocation < location {
        range.startIndex = midIndex + 1
      } else {
        range.endIndex = midIndex
        nextBlockIndex = midIndex
      }
    }
    
    return (chars[nextBlockIndex], true)
  }
  
  /// Check if current character match with pattern
  private func matchTextCharacter(textCharacter: Character, withMaskCharacter maskCharacter: AKMaskFieldBlockCharacter) -> Bool {
    return !AKMaskFieldUtility
      .matchesInString(String(textCharacter),
                       pattern: maskCharacter.pattern.pattern()).isEmpty
  }
  
  private func updateMaskTemplateText() {
    AKMaskFieldUtility
      .replacingOccurrencesOfString(&maskTemplateText,
                                    target     : "[\(maskBlockBrackets.left)\(maskBlockBrackets.right)]",
                                    withString : "")
    
    maskText = maskTemplateText
    
    refreshMask()
  }
  
  private func updateMaskTemplateTextFromBlock(index: Int) {
    
    
    print(maskTemplateText)
    
    AKMaskFieldUtility
      .replace(&maskTemplateText,
               withString : maskBlocks[index].template,
               inRange    : maskBlocks[index].patternRange)
  }
  
  private struct AKMaskFieldProcessedBlock {
    var range  : NSRange?
    var string : String = ""
  }
  
}
//  MARK: - UITextFieldDelegate

extension AKMaskField: UITextFieldDelegate {
  
  public func textFieldDidBeginEditing(textField: UITextField) {
    if guardMask { return }
    
    var position: Int
    
    switch maskStatus {
    case .Clear       : position = maskBlocks.first!.templateRange.location
    case .Incomplete  : position = maskBlocks.flatMap { $0.chars.filter { $0.status == .Clear } }.first!.templateRange.location
    case .Complete    : position = maskBlocks.last!.templateRange.toRange()!.endIndex
    }

    AKMaskFieldUtility.maskField(self, moveCaretToPosition: position)
  }
  
  public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    // CHECKS
    
    if guardMask { return false }
    
    let maskBlocksChars = maskBlocks.flatMap { $0.chars }
    
    // EVENTS
    
    var event: AKMaskFieldEvent!
    
    var completed: Int = 0
    var cleared: Int   = 0
    
    // PREPARE BLOCKS FOR USER PROCESSING
    
    var processedBlocks = [AKMaskFieldProcessedBlock]()
    
    // - - - - - - - - - - - -
    // STEP 1
    // Selected range
    
    // Find blocks with text which must be reset 
    
    // a) Prepare an array with interserted ranges
    
    let intersertRanges = AKMaskFieldUtility
      .findIntersection(maskBlocks.map { return $0.templateRange }, withRange: range)
    
    // b) Create an array with interserted blocks
    
    for (i, intersertRange) in intersertRanges.enumerate() {

      var processedBlock = AKMaskFieldProcessedBlock()
      processedBlock.range = intersertRange
      
      if let intersertRange = intersertRange {
        processedBlock.range?.location = abs(maskBlocks[i].templateRange.location - intersertRange.location)
      }
      processedBlocks.append(processedBlock)
    }
    
    // - - - - - - - - - - - -
    // STEP 2
    // Replacement string
    
    var location      = range.location
    var savedLocation = range.location
    
    for replacementCharacter in string.characters {
      if location == maskText?.characters.count { break }

      // Find next character
      // If character outside the block, jump to first character of the next block
      print("location \(location)")
      let nextCharacter = getNetCharacter(maskBlocksChars, fromLocation: location)
      print(nextCharacter)
      
      var findMatches: Bool = false

      if nextCharacter.outsideBlock {

        // Check if replacement character match to mask template character in same location
        
        if replacementCharacter != Character(AKMaskFieldUtility.substring(maskTemplateText, withNSRange: NSMakeRange(location, 1))) &&
           replacementCharacter != " " {
          
            savedLocation = location
            findMatches = true
        }
      } else {
        findMatches = true
      }

      if findMatches {
        if matchTextCharacter(replacementCharacter, withMaskCharacter: nextCharacter.char) {
          
          location = nextCharacter.char.templateRange.location
          let blockIndex = nextCharacter.char.blockIndex
          
          processedBlocks[blockIndex].string.append(replacementCharacter)
          
          if processedBlocks[blockIndex].range == nil {
            processedBlocks[blockIndex].range =  NSMakeRange(nextCharacter.char.index, 0)
          }
        } else {
          
          location = savedLocation
          
          event = .Error
          break
        }
      }
      
      location += 1
    }
    
    // USER PROCESSING

    for (i, processedBlock) in processedBlocks.enumerate() {
      if var _range = processedBlock.range {
      
        // Prepare data
          
        var _string = processedBlock.string
   
        // Grab all changed data
        let shouldChangeBlock = maskDelegate?
          .maskField(self,
                     shouldChangeBlock : maskBlocks[i],
                     inRange           : &_range,
                     replacementString : &_string)
          ?? true
          
        if shouldChangeBlock {

          // REVALIDATE
          
          // - - - - - - - - - - - -
          // Selected range
          
          if  processedBlock.range!.location != _range.location ||
              processedBlock.range!.length   != _range.length {
            
            if let validatedRange = AKMaskFieldUtility
              .findIntersection([maskBlocks[i].templateRange], withRange: _range).first! as NSRange? {
              
              _range = validatedRange
            }
          }
          
          // - - - - - - - - - - - -
          // Replacement string
          
          if processedBlock.string != _string {
            
            var validatedString = ""
            
            // Start carret position
            var _location = _range.location
            
            for replacementCharacter in _string.characters {
              if _location > maskBlocks[i].templateRange.length { break }

              if matchTextCharacter(replacementCharacter, withMaskCharacter: maskBlocks[i].chars[_location]) {
                validatedString.append(replacementCharacter)
              } else {
                event = .Error
                break
              }
              _location += 1
            }
            
            _string = validatedString
          }
          
          // UPDATE MASK TEXT
          
          // - - - - - - - - - - - -
          // Replacement string
          
          if !_string.isEmpty {
            
            var maskTextRange = NSMakeRange(_range.location, _string.characters.count)
            
            // Object
            
            print(maskTextRange)
            print(_string)
            
            for index in maskTextRange.toRange()! {
              
              print(index)
              
              maskBlocks[i].chars[index].status = .Complete
              completed += 1
            }
            
            maskTextRange.location += maskBlocks[i].templateRange.location

            // Mask text
            
            AKMaskFieldUtility
              .replace(&maskText,
                       withString : _string,
                       inRange    : maskTextRange)
            
            
            // New carret position
            location = maskTextRange.toRange()!.endIndex
            
            event = .Insert
            
            // Prepare range for clearing
            
            _range.location += maskTextRange.length
            _range.length   -= maskTextRange.length
          }
          
          // - - - - - - - - - - - -
          // Selected range
          
          if _range.length > 0 {
            
            var maskTextRange = _range
            
            // Object
            
            for index in _range.toRange()! {
              maskBlocks[i].chars[index].status = .Clear
              cleared += 1
            }
            
            // Mask text
            
            maskTextRange.location += maskBlocks[i].templateRange.location
            
            let cuttedTempalte = AKMaskFieldUtility
              .substring(maskTemplateText, withNSRange: maskTextRange)

            AKMaskFieldUtility
              .replace(&maskText,
                       withString : cuttedTempalte,
                       inRange    : maskTextRange)
            
          }
        }
      }
    }
    
    // - - - - - - - - - - - -
    // EVENT
    // - - - - - - - - - - - -
    
    if completed != 0 {
      event = cleared == 0 ? .Insert : .Replace
    } else {
      if cleared != 0 {
        event = .Delete
      }
    }
    
    if let event = event {
      maskDelegate?.maskField(self, didChangedWithEvent: event)
    }
    
    // - - - - - - - - - - - -
    // DISPLAYED TEXT
    // - - - - - - - - - - - -
    
    refreshMask()
  
    AKMaskFieldUtility.maskField(self, moveCaretToPosition: location)
    
    return false
  }

  private func debugmaskBlocks() {
    for block in maskBlocks {
      print("BLOCK :")
      print("index          : \(block.index)")
      print("status         : \(block.status)")
      print("pattern        : \(block.pattern)")
      print("patternRange   : \(block.patternRange)")
      print("template       : \(block.template)")
      print("templateRange  : \(block.templateRange)")
      print("CHARS :")
      for char in block.chars {
        print("   index           : \(char.index)")
        print("   blockIndex      : \(char.blockIndex)")
        print("   status          : \(char.status)")
        print("   pattern         : \(char.pattern)")
        print("   patternRange    : \(char.patternRange)")
        print("   template        : \(char.template)")
        print("   templateRange   : \(char.templateRange)")
      }
      print("")
    }
  }
}

//  MARK: - AKMaskFieldDelegate

public protocol AKMaskFieldDelegate: class {

  /// Asks the delegate if editing should begin in the specified mask field.
  ///
  /// - parameter maskField : The mask field in which editing is about to begin.
  func maskFieldDidBeginEditing(maskField: AKMaskField)
  
  /// Tells the delegate that editing stopped for the specified mask field.
  ///
  /// - parameter maskField : The mask field for which editing ended.
  func maskFieldDidEndEditing(maskField: AKMaskField)
  
  /// Tells the delegate that specified mask field change text with event.
  ///
  /// - parameter maskField : The mask field for which event changed.
  /// - parameter event : Event constant value received after manipulations.
  func maskField(maskField: AKMaskField, didChangedWithEvent event: AKMaskFieldEvent)
  
  /// Asks the delegate if the specified mask block should be changed.
  ///
  /// - parameter maskField : The mask field containing the text.
  /// - parameter block : Target block
  /// - parameter range : The range of characters to be replaced (inout parameter).
  /// - parameter string : The replacement string for the specified range (inout parameter).
  func maskField(maskField: AKMaskField, shouldChangeBlock block: AKMaskFieldBlock, inRange range:  NSRange,  replacementString string: String) -> Bool
}

extension AKMaskFieldDelegate {
  func maskFieldDidBeginEditing(maskField: AKMaskField) {}
  func maskFieldDidEndEditing(maskField: AKMaskField) {}
  func maskField(maskField: AKMaskField, didChangedWithEvent event: AKMaskFieldEvent) {}
  func maskField(maskField: AKMaskField, shouldChangeBlock block: AKMaskFieldBlock, inRange range: NSRange, replacementString string: String) -> Bool {
        return true
  }
}
