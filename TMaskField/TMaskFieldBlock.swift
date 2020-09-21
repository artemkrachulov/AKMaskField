import Foundation

/// A structure that contains the mask block main properties.

public struct TMaskFieldBlock {
    
    //  MARK: - General
    
    /// Block index in the mask
    
    public var index: Int
    
    /// Returns the current block status.
    
    public var status: TMaskFieldStatus {
        
        let completedChars: [TMaskFieldBlockCharacter] = chars.filter { return $0.status != .clear }
        
        switch completedChars.count {
        case 0           : return .clear
        case chars.count : return .complete
        default          : return .incomplete
        }
    }
    
    /// An array containing all characters inside block.
    
    public var chars: [TMaskFieldBlockCharacter]
    
    //  MARK: - Pattern
    
    /// The mask pattern that represent current block.
    
    public var pattern: String {
        
        var pattern: String = ""
        for char in chars {
            pattern += char.pattern.rawValue
        }
        return pattern
    }
    
    /// Location of the mask pattern in the mask.
    
    public var patternRange: NSRange {
        return NSMakeRange(chars.first!.patternRange.location, chars.count)
    }
    
    //  MARK: - Mask template
    
    /// The mask template string that represent current block.
    
    public var template: String {
        var template: String = ""
        for char in chars {
            template.append(char.template)
        }
        return template
    }
    
    /// Location of the mask template string in the mask template.
    
    public var templateRange: NSRange {
        return NSMakeRange(chars.first!.templateRange.location, chars.count)
    }
    
    
}
