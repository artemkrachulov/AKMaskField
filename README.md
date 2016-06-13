# AKMaskField

![Preview](https://raw.githubusercontent.com/artemkrachulov/AKMaskField/master/Assets/preview.gif)

AKMaskField is UITextField subclass which allows enter data in the fixed quantity and in the certain format (credit cards, telephone numbers, dates, etc.). You only need setup mask string and mask template string visible for user.

## Features

* Easy in use
* Possibility to setup input field from a code or Settings Panel
* Smart template
* Support of dynamic change of a mask
* Fast processing of a input field
* Smart copy / insert action

## Requirements

- iOS 8.0+
- Xcode 7.3+

## Installation

1. Clone or download demo project.
2. Add the AKMaskField folder to your project (To copy the file it has to be chosen).

## Usage

### Storyboard

Create a text field `UITextField` and set a class `AKMaskField` in the Inspector / Accessory Panel tab. Specify necessary attributes in the Inspector / Accessory Attributes tab.

Example:

* **Mask**: {dddd}-{DDDD}-{WaWa}-{aaaa}
* **Mask Template**: ABCD-EFGH-IJKL-MNOP

Drag field to view controller class. Create outlet.

```swift
@IBOutlet weak var field: AKMaskField!
```

### Programmatically

Setup mask field in your view controller.

```swift
var field: AKMaskField!

override func viewDidLoad() {
    super.viewDidLoad()

    field = AKMaskField()
    field.mask = "{dddd}-{DDDD}-{WaWa}-{aaaa}"
    field.maskTemplate = "ABCD-EFGH-IJKL-MNOP"
}
```

### Run

```swift
// Output
// ABCD-EFGH-IJKL-MNO
```
> You can also set other properties like `text`, `placeholder`, etc.
> Example if you will set `text` property to value `1234`. A mask field will show `0123-EFGH-IJKL-MNOP` after loading view controller.
> Or if `placeholder` property will be not empty you will see placeholder text (oly when mask field is clear).

### Set new text

```swift
func updateText(text: String?)
```
Will update text in the mask field.
Parameters:

* `text` :  The text, that you want to display by the mask field.

> This property updated manually when user type anything in the mask field.



## Set up mask
### Properties

```swift
var mask: String?
```

The string value that contains blocks with symbols that determines certain format of input data. Each block must be wrapped in brackets. Default brackets value is `{ ... }`.
The predetermined formats:

* `d` : Number, decimal number from 0 to 9
* `D` : Any symbol, except decimal number
* `W` : Not an alphabetic symbol
* `a` :  Alphabetic symbol, a-Z
* `.` :  Corresponds to any symbol (default)

This property is empty by default.

```swift
var maskTemplate: String
```

The text that represents the mask filed with replacing format symbol with template characters.
Can be set (characters count):
* `1` : This character will be copied in each block and will replace mask format symbol.
* `Same length as mask without brackets` : Template character will replace mask format symbol in same position.

The initial value of this property is `*`.

### Methods

```swift
func setMask(mask: String, withMaskTemplate maskTemplate: String!)
```

Set up mask field mask field. Parameters listed before.

### Configuring mask

```swift
var maskBlockBrackets: AKMaskFieldBrackets
```

Two characters (opening and closing bracket for the block mask).
The initial values is `{` and `}`.

### Accessing the Delegate

```swift
weak var maskDelegate: AKMaskFieldDelegate?
```

A mask field delegate responds to editing-related messages from the mask field. All delegate methods listed below.

## Properties
### Mask object

```swift
var maskObject: [AKMaskFieldBlock]? {get}
```

An array with all mask blocks mask defined as `AKMaskFieldBlock` structure.

```swift
struct AKMaskFieldBlock {
  var index: Int
  var status: Bool
  var range: Range<Int>
  var mask: String
  var template: String
  var chars: [AKMaskFieldBlockChars]
}
```

* `index` : Block position number in the mask
* `status` : Current block complete status
* `range` : Block range in the mask (without brackets)
* `mask` : Mask characters inside this block between brackets
* `template` : Mask template placeholder corresponding mask characters inside this block
* `chars` :  Characters list with parameters

`AKMaskFieldBlockChars` structure.
```swift
struct AKMaskFieldBlockChars {
  var index: Int
  var status: Bool
  var range: Range<Int>
  var text: Character?
}
```

* `index` : Character position number in the mask block
* `status` : Current character complete status
* `range` : Character range in the mask (without brackets)
* `text` : Current character

The initial value of this property is `nil`.

### Status of the mask

```swift
var maskStatus: AKMaskFieldStatus
```

Current status of the mask field representes as `AKMaskFieldStatus` enumeration type.

```swift
enum AKMaskFieldStatus {
  case Clear
  case Incomplete
  case Complete
}
```
* `Clear` : No one character was entered
* `Incomplete` : At least one character is not entered
* `Complete` : All characters was entered

The initial value of this property is `Clear`.

## Delegate methods

```swift
optional func maskFieldDidBeginEditing(maskField: AKMaskField)
```
Tells the delegate that editing began for the specified mask field `maskField`.

```swift
optional func maskFieldDidEndEditing(maskField: AKMaskField)
```

Tells the delegate that editing finished for the specified mask field.

```swift
optional func maskField(maskField: AKMaskField, didChangeCharactersInRange range: NSRange, replacementString string: String, withEvent event: AKMaskFieldEvent)
```

Tells the delegate that specified mask field `maskField` change text with event.

Parameters:

* `range` : The range of characters to be replaced
* `string` : The replacement string
* `event` : Defines a user event, `AKMaskFieldEvet` enumeration type
    ```swift
    enum AKMaskFieldEvet {
        case None
        case Insert
        case Delete
        case Replace
    }
    ```
    * `Error` : Error with placing new character.
    * `Insert` : Entering new text
    * `Delete` : Deleting text from field
    * `Replace` : Selecting and replacing or deleting text

---

Please do not forget to ★ this repository to increases its visibility and encourages others to contribute.

### Author

Artem Krachulov: [www.artemkrachulov.com](http://www.artemkrachulov.com/)
Mail: [artem.krachulov@gmail.com](mailto:artem.krachulov@gmail.com)

### License

Released under the [MIT license](http://www.opensource.org/licenses/MIT)
