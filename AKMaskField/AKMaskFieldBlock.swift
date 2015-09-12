//
//  AKMaskFieldBlock.swift
//  AKMaskField
//  GitHub: https://github.com/artemkrachulov/AKMaskField
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import Foundation

struct AKMaskFieldBlock {    
    var index: Int
    var status: Bool
    var range: Range<Int>
    var mask: String
    var text: String
    var template: String
    var chars: [AKMaskFieldBlockChars]
}