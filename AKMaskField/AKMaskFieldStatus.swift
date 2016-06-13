//
//  AKMaskFieldStatus.swift
//  AKMaskField
//  GitHub: https://github.com/artemkrachulov/AKMaskField
//
//  Created by Artem Krachulov
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//
// v. 0.1
//

import Foundation

enum AKMaskFieldStatus {
  
  /// No one character was entered
  case Clear
  
  /// At least one character is not entered
  case Incomplete
  
  /// All characters was entered
  case Complete
}