//
//  AKMaskFieldBlock.swift
//  AKMaskField
//  GitHub: https://github.com/artemkrachulov/AKMaskField
//
//  Created by Artem Krachulov
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//
// v. 0.1
//

struct AKMaskFieldBlock {
  /// Block position number in the mask
  var index: Int
  
  /// Current block complete status
  var status: Bool
  
  /// Block range in the mask (without brackets)
  var range: Range<Int>
  
  /// Mask characters inside this block between brackets
  var mask: String
  
  /// Mask template placeholder corresponding mask characters inside this block
  var template: String
  
  /// Characters list with parameters
  var chars: [AKMaskFieldBlockChars]
}