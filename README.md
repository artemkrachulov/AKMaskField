# AKMaskField

<p align="center">
    <img src="https://raw.githubusercontent.com/artemkrachulov/AKMaskField/master/Assets/preview.png" alt="Preview">
</p>

AKMaskField allows the user to enter easily data in the fixed quantity and in certain format (credit cards, telephone numbers, dates, etc.). The developer needs to adjust a format of a mask and a template. The mask consists of symbols and blocks. Each block consists of symbols of a certain type (number, letter, symbol). The template in turn represents a mask with hidden symbols in each block.

**Features:**

* Easy in use
* Possibility to setup input field from a code or Settings Panel
* Smart template
* The status and action callbacks
* Support of dynamic change of a mask
* Fast processing of a input field
* Smart user input actions: to copy / insert

## Usage

Add the _AKMaskField_ folder to your project (To copy the file it has to be chosen).

### Storyboard

Create a text field _UITextField_ and specify set new class _AKMaskField_ in the Inspector / Accessory Panel. Specify necessary attributes in the Inspector / Accessory Attributes tab:

**Mask**: {dddd}-{DDDD}-{WaWa}-{aaaa}<br>
**Mask Template**: ABCD-EFGH-IJKL-MNOP<br>
**Mask Show Template**: On

Drag field, move to Controller class. Create outlet.

### Storyboard

```swift
@IBOutlet weak var field: AKMaskField!
```

### Programmatically

```swift
var field: AKMaskField!

override func viewDidLoad() {
    super.viewDidLoad()

    field = AKMaskField()
    field.mask = "{dddd}-{DDDD}-{WaWa}-{aaaa}"
    field.maskTemplate = "ABCD-EFGH-IJKL-MNOP"
    field.maskShowTemplate = true
}
```
### Other properties

You can also set other properties like `text`, `placeholder`, etc.
Example if you set `text` property to 1234. Field will show `0123-EFGH-IJKL-MNOP` after loading view controller.

## Initializing

Same initialization as `UITextField` class.

## Properties

### Displaying mask

```swift
var mask: String
```

The string value that contains blocks with symbols that determines certain type of input data. Each block must be wrapped by brackets. Default brackets `{ ... }`.
The predetermined types of input data:

| Type  | Description    |
| ----- | :------------- |
| **d** | Number, decimal number from 0 to 9. |
| **D** | Any symbol, except decimal number. |
| **W** | Not an alphabetic symbol. |
| **a** | Alphabetic symbol, a-Z. |
| **.** | Corresponds to any symbol (by default) |

The initial value of this property is `nil`.
Example: `{dddd}-{DDDD}-{WaWa}-{aaaa}`

```swift
var maskTemplate: String
```

The string that is displayed over mask. Each input type symbol will replaced with template character. You can set:

| Characters count                         | Description    |
| :--------------------------------------- | :------------- |
| **1**                                    | This character will be copied to each block and will replace mask input type symbol. |
| **Same length as mask without brackets** | Template character will replace mask input type symbol in same position. |

The initial value of this property is `*`.

```swift
var maskShowTemplate: Bool
```

A Boolean value indicating will text field show mask template after initialization.<br>
The initial value of this property is `false`.

### Configuring mask

```swift
var maskBlockBrackets: [Character]
```

Array with two characters (open and close bracket for bock mask).<br>
The initial value of this property is `{` and `}`.

### Mask object

```swift
var maskObject: [AKMaskFieldBlock]! {get}
```

Array with all mask blocks. Each block value defined as AKMaskFieldBlock structure.<br>
The initial value of this property is `nil`.

#### Mask block

```swift
var index: Int
```

Block index in the mask.

```swift
var status: Bool
```

A Boolean value that determines block filled satus in current moment.

```swift
var range: Range<Int>
```

The block position in a mask string.

```swift
var mask: String
```

The block mask without brackets.

```swift
var text: String
```

Entered characters in the block.

```swift
var template: String
```

The block template string.

```swift
var chars: [AKMaskFieldBlockChars]
```

All block characters array. Each character value defined as AKMaskFieldBlockChars structure.

#### The block characters

```swift
var index: Int
```

Character index in the block.

```swift
var status: Bool
```

A Boolean value that determines character filled satus in current moment.

```swift
var text: String
```

Entered character.

```swift
var range: Range<Int>
```

Character position in a mask string.

### States and enents

```swift
var maskStatus: AKMaskFieldStatus
```

Define a state of a mask field at the current moment. The field has 3 states and defined as `AKMaskFieldStatus` enumeration type.

```swift
enum AKMaskFieldStatus {
    case Clear
    case Incomplete
    case Complete
}
```

| State          | Description    |
| :------------- | :------------- |
| **Clear**      | No character was entered. |
| **Incomplete** | At least one character is not entered. |
| **Complete**   | All mask character are entered. |


The initial value of this property is `AKMaskFieldStatus.Clear`.

```swift
var maskEvent: AKMaskFieldEvet
```

Define a user events. The user can make 4 events, all events defined as `AKMaskFieldEvet` enumeration type.

```swift
enum AKMaskFieldEvet {
    case None
    case Insert
    case Delete
    case Replace
}
```

| State       | Description    |
| :-----------| :------------- |
| **None**    | Not events. |
| **Insert**  | Entering new text . |
| **Delete**  | Deleting text from field. |
| **Replace** | Selecting and replacing or deleting text. |

The initial value of this property is `AKMaskFieldEvet.None`.

### Accessing the Delegate

```swift
weak var maskDelegate: AKMaskFieldDelegate?
```

A text field delegate responds to editing-related messages from the text field. You can use the delegate to respond to the text entered by the user and to some special commands, such as when the return button is pressed.

## Delegate methods

```swift
optional func maskFieldDidBeginEditing(maskField: AKMaskField)
```

| Parameter     | Description    |
| :------------ | :------------- |
| maskField     | The mask field for which an editing session began. |

Tells the delegate that editing began for the specified text field.


```swift
optional func maskField(maskField: AKMaskField,
 shouldChangeCharacters oldString: String,
                inRange range: NSRange,
      replacementString withString: String)
```

| Parameter     | Description    |
| :------------ | :------------- |
| maskField     | The text field containing the text. |
| oldString     | The string that will replaced. |
| range         | The range of characters to be replaced. |
| withString    | The replacement string. |

Asks the delegate if the specified text should be changed.

## Tips

### How get entered text without mask

```swift
var enteredText: String = ""
for block in self.field.maskObject {

    for char in block.chars {
        if char.status { enteredText += String(char.text) }
    }
}

println("Entered text: \(enteredText)")
```

### Author

Artem Krachulov: [www.artemkrachulov.com](http://www.artemkrachulov.com/), email [artem.krachulov@gmail.com](mailto:artem.krachulov@gmail.com)

### License

Released under the [MIT license](http://www.opensource.org/licenses/MIT)