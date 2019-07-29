//
//  AKMaskFieldPatternCharacter.swift
//  AKMaskField
//  GitHub: https://github.com/artemkrachulov/AKMaskField
//
//  Created by Artem Krachulov
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

/// Single block character pattern constant.
import UIKit

public enum AKMaskFieldPatternCharacter: String {
    
    //  MARK: - Constants
    
    case NumberDecimal      = "d"
    case NonDecimal         = "D"
    case NonWord            = "W"
    case Alphabet           = "a"
    case Cirillic           = "k"
    case AnyChar            = "."
    case AlphabetOrDecimal  = ":"
    
    /// Returns regular expression pattern.
    
    public func pattern() -> String {
        switch self {
        case .NumberDecimal     : return "\\d"
        case .NonDecimal        : return "\\D"
        case .NonWord           : return "\\W"
        case .Alphabet          : return "[a-zA-Z]"
        case .Cirillic          : return "[а-яА-Я]"
        case .AlphabetOrDecimal : return "[a-zA-Zа-яА-Я0-9]"
        default                 : return "."
        }
    }
    
    func keyboardType() -> UIKeyboardType {
        switch self {
        case .NumberDecimal   : return .decimalPad
        default               : return .default
        }
    }
}
