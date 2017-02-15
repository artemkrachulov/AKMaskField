# AKMaskField

[![Carthage compatible][carthage-bage]][carthage-bage] 
[![CocoaPods Compatible][pods-bage]][pods-bage]

[![Platform][platform-bage]][platform-bage]
[![Swift Version][swift-bage]][swift-url]
[![Build Status][travis-bage]][travis-url]
[![License][license-bage]][license-url]

[pods-bage]: https://img.shields.io/badge/COCOAPODS-compatible-fb0006.svg
[pods-url]: https://cocoapods.org/
[carthage-bage]: https://img.shields.io/badge/Carthage-compatible-brightgreen.svg
[carthage-url]: https://github.com/Carthage/Carthage
[platform-bage]: https://img.shields.io/cocoapods/p/LFAlertController.svg
[platform-url]: http://cocoapods.org/pods/LFAlertController
[swift-bage]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-bage]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-bage]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
AKMaskField is UITextField subclass which allows enter data in the fixed quantity and in the certain format (credit cards, telephone numbers, dates, etc.). You only need setup mask and mask template visible for user.

![Preview](header.gif)

## Features

- [x] Easy in use
- [x] Possibility to setup input field from a code or Settings Panel
- [x] Smart template
- [x] Support of dynamic change of a mask
- [x] Fast processing of a input field
- [x] Smart copy / insert action

## Requirements

- iOS 8.0+
- Xcode 7.3+

## Installation

### CocoaPods

[CocoaPods][] is a dependency manager for Cocoa projects. To install **AKMaskField** with CocoaPods:

 1. Make sure CocoaPods is [installed][CocoaPods Installation].

 2. Update your Podfile to include the following:

	``` ruby
	use_frameworks!
	pod 'AKMaskField'
	```

 3. Run `pod install`.

[CocoaPods]: https://cocoapods.org
[CocoaPods Installation]: https://guides.cocoapods.org/using/getting-started.html#getting-started
 
 4. In your code import **AKMaskField** like so: `import AKMaskField`

### Carthage

[Carthage][] is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.
To install **AKMaskField** with Carthage:

1. Install Carthage via [Homebrew][]

	```bash
	$ brew update
	$ brew install carthage
	```

2. Add `github "artemkrachulov/AKMaskField"` to your Cartfile.

3. Run `carthage update`.

4. Drag `AKMaskField.framework ` from the `Carthage/Build/iOS/` directory to the `Linked Frameworks and Libraries` section of your Xcode project’s `General` settings.

5. Add `$(SRCROOT)/Carthage/Build/iOS/AKMaskField.framework ` to `Input Files` of Run Script Phase for Carthage.

[Carthage]: https://github.com/Carthage/Carthage
[Homebrew]: http://brew.sh

### Manual

If you prefer not to use either of the aforementioned dependency managers, you can integrate **AKMaskField** into your project manually.

1. Download and drop **AKMaskField** folder in your project.
2. Done!

## Usage example

### Storyboard

Create a text field `UITextField` and set a class `AKMaskField` in the Inspector / Accessory Panel tab. Specify necessary attributes in the Inspector / Accessory Attributes tab.

Example:

* **MaskExpression**: {dddd}-{DDDD}-{WaWa}-{aaaa}
* **MaskTemplate**: ABCD-EFGH-IJKL-MNOP


### Programmatically

Setup mask field in your view controller.

```swift
var field: AKMaskField!

override func viewDidLoad() {
    super.viewDidLoad()

    field = AKMaskField()
    field.maskExpression = "{dddd}-{DDDD}-{WaWa}-{aaaa}"
    field.maskTemplate = "ABCD-EFGH-IJKL-MNOP"
}
```

## Configuring the Mask Field

```swift
var maskExpression: String?
```

The string value that has blocks with pattern symbols that determine the certain format of input data. Wrap each mask block with proper bracket character.

**The predetermined formats**: 

| Mask symbol (pattern)   | Input format |
| :-----------: | :------------ |
| **d** | Number, decimal number from 0 to 9 |
| **D** | Any symbol, except decimal number |
| **W** | Not an alphabetic symbol |
| **a** | Alphabetic symbol, a-Z | 
| **.** | Corresponds to any symbol (default) |

Default value of this property is `nil`.

```swift
var maskTemplate: String
```

The text that represents the mask filed with replacing mask symbol by template character.

| Characters count   | Input format |
| :-----------: | :------------ |
| **1** | Template character will be copied to each mask block with repeating equal block length. |
| **Equal** | Template length equal to mask without brackets. Template characters will replace mask blocks in same range.|

Default value of this property is `*`.

```swift
func setMask(mask: String, withMaskTemplate maskTemplate: String)
```

Use this method to set the mask and template parameters.

**Parameters**

- `maskExpression` : Mask (read above).
- `maskTemplate` : Mask template (read above).

> You can also set default `placeholder` property. The placeholder will shows only when mask field is clear.


```swift
var maskBlockBrackets: AKMaskFieldBrackets
```

Open and close bracket character for the mask block.
Default value of this property is `{` and `}`.

## Setup Mask Field behavior 

```swift
var jumpToPrevBlock: Bool { get set }
```

Jumps to previous block when cursor placed between brackets or before first character in current block. 
Default value of this property is `false`.

## Accessing the Text Attributes

```swift
var text: String? { get set }
```

The text displayed by the mask field. 

## Mask Field actions

```swift
func refreshMask()
```

Manually refresh the mask field


## Accessing the Delegate

```swift
weak var maskDelegate: AKMaskFieldDelegate? { get set }
```

The receiver’s delegate.

## Getting the Mask Field status

```swift
var maskStatus: AKMaskFieldStatus { get }
```

Returns the current status of the mask field. The value of the property is a constant. See **AKMaskFieldStatus** for descriptions of the possible values.

## Getting the Mask Field object

```swift
var maskBlocks: [AKMaskFieldBlock] { get }
```

Returns an array containing all the Mask Field blocks

## AKMaskFieldDelegate

### Managing Editing

```swift
optional func maskFieldShouldBeginEditing(maskField: AKMaskField) -> Bool
```

Asks the delegate if editing should begin in the specified mask field.

**Parameters**

- `maskField` : The mask field in which editing is about to begin. 

```swift
optional func maskFieldDidBeginEditing(maskField: AKMaskField)
```

Asks the delegate if editing should begin in the specified mask field.

**Parameters**

- `maskField` : The mask field in which editing is about to begin. 

```swift
optional func maskFieldShouldEndEditing(maskField: AKMaskField) -> Bool
```

Asks the delegate if editing should stop in the specified mask field.

**Parameters**

- `maskField` : The mask field in which editing is about to end.

```swift
optional func maskFieldDidEndEditing(maskField: AKMaskField)
```

Tells the delegate that editing stopped for the specified mask field.

**Parameters**

- `maskField` : The mask field for which editing ended.

```swift
optional func maskField(maskField: AKMaskField, didChangedWithEvent event: AKMaskFieldEvent)
```

Tells the delegate that specified mask field change text with event.

**Parameters**

- `maskField` : The mask field for which event changed.
- `event` : Event constant value received after manipulations.

### Editing the Mask Field’s Block

```swift
optional func maskField(maskField: AKMaskField, shouldChangeBlock block: AKMaskFieldBlock, inout inRange range: NSRange, inout replacementString string: String) -> Bool
```

Asks the delegate if the specified mask block should be changed.

**Parameters**

- `maskField` : The mask field containing the text.
- `block` : Target block. See ** AKMaskFieldBlock** more information.
- `range` : The range of characters to be replaced (inout parameter).
- `string` : The replacement string for the specified range (inout parameter).

## Structures

### AKMaskFieldBlock

A structure that contains the mask block main properties.

**General**

```swift
var index: Int
```

Block index in the mask

```swift
var status: AKMaskFieldStatus { get }
```

Returns the current block status.

```swift
var chars: [AKMaskFieldBlockCharacter]
```

An array containing all characters inside block. See `AKMaskFieldBlockCharacter` structure information.

**Pattern**

```swift
var pattern: String { get }
```

The mask pattern that represent current block.

```swift
var patternRange: NSRange { get }
```

Location of the mask pattern in the mask.

**Mask template**

```swift
var template: String { get }
```

The mask template string that represent current block.

```swift
var templateRange: NSRange { get }
```

Location of the mask template string in the mask template.

### AKMaskFieldBlockCharacter

A structure that contains the block character main properties.

**General**

```swift
var index: Int
```

Character index in the block.

```swift
var blockIndex: Int
```

The block index in the mask.

```swift
var status: AKMaskFieldStatus
```

Current character status.

**Pattern**

```swift
var pattern: AKMaskFieldPatternCharacter
```

The mask pattern character. See `AKMaskFieldPatternCharacter` costant information.

```swift
var patternRange: NSRange
```

Location of the pattern character in the mask.

**Mask template**

```swift
var template: Character
```

The mask template character.

```swift
var templateRange: NSRange
```

Location of the mask template character in the mask template.

## Constants

### AKMaskFieldStatus

```swift
enum AKMaskFieldStatus {
	case Clear
	case Incomplete
	case Complete
}
```

The Mask Field, Block and Block Character status property constant.

### AKMaskFieldEvent

```swift
enum AKMaskFieldEvet {
	case None
	case Insert
	case Delete
	case Replace
}
```

Event constant value received after manipulations with the Mask Field.

### AKMaskFieldPatternCharacter

```swift
enum AKMaskFieldPatternCharacter: String {
  case NumberDecimal = "d"
  case NonDecimal = "D"
  case NonWord = "W"
  case Alphabet = "a"
  case Any = "."
}
```

Single block character pattern constant.

**Constatns**

- `NumberDecimal`	: Number, decimal number from 0 to 9
- `NonDecimal`	: Any symbol, except decimal number
- `NonWord`	: Not an alphabetic symbol
- `Alphabet`	: Alphabetic symbol, a-Z
- `Any`	: Corresponds to any symbol (default)

```swift
func pattern() -> String
```

Returns regular expression pattern.

## Contribute

Please do not forget to ★ this repository to increases its visibility and encourages others to contribute. 

Got a bug fix, or a new feature? Create a pull request and go for it!

## Meta

Artem Krachulov – [www.artemkrachulov.com](http://www.artemkrachulov.com/) - [artem.krachulov@gmail.com](mailto:artem.krachulov@gmail.com)

Released under the [MIT license](http://www.opensource.org/licenses/MIT)

[https://github.com/artemkrachulov](https://github.com/dbader/)