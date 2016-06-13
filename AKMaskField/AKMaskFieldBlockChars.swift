//
//  AKMaskFieldBlockChars.swift
//  AKMaskField
//  GitHub: https://github.com/artemkrachulov/AKMaskField
//
//  Created by Artem Krachulov
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//
// v. 0.1
//

struct AKMaskFieldBlockChars {
  /// Character position number in the mask block
  var index: Int
  
  /// Current character complete status
  var status: Bool
  
  /// Character range in the mask (without brackets)
  var range: Range<Int>
  
  /// Current character
  var text: Character?
}