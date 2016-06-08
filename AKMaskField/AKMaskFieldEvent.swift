//
//  AKMaskFieldEvent.swift
//  AKMaskField
//  GitHub: https://github.com/artemkrachulov/AKMaskField
//
//  Created by Artem Krachulov
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import Foundation

enum AKMaskFieldEvent {
  /// Error with placing new character
  case Error
  
  /// Entering new text
  case Insert
  
  /// Deleting text from field
  case Delete
  
  /// Selecting and replacing or deleting text
  case Replace
}