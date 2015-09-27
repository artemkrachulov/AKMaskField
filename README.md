# AKMaskField

<p align="center">
    <img src="https://raw.githubusercontent.com/artemkrachulov/AKMaskField/master/Assets/preview.png" alt="Preview">
</p>

AKMaskField allows the user to enter easily data in the fixed quantity and in the certain format (credit cards, telephone numbers, dates, etc.). The developer need to set a mask and template string. The mask contain blocks and other characters. Each block contain of symbols of a certain type (number, letter, symbol). The template represents the mask with replacing format symbol with template characters.

**Features:**

* Easy in use
* Possibility to setup input field from a code or Settings Panel
* Smart template
* Support of dynamic change of a mask
* Fast processing of a input field
* Smart copy / insert action

## Usage

Add the _AKMaskField_ folder to your project (To copy the file it has to be chosen).

### Storyboard

Create a text field `UITextField` and set a class `AKMaskField` in the Inspector / Accessory Panel tab. Specify necessary attributes in the Inspector / Accessory Attributes tab:

**Mask**: {dddd}-{DDDD}-{WaWa}-{aaaa}<br>
**Mask Template**: ABCD-EFGH-IJKL-MNOP<br>
**Mask Show Template**: On<br>

Drag field to view controller class. Create outlet.

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
Example if you will set `text` property to value `1234`. A mask field will show `0123-EFGH-IJKL-MNOP` after loading view controller.

## Initializing

Same initialization as `UITextField` class.

## Properties

### Displaying mask

```swift
var mask: String
```

The string value that contains blocks with symbols that determines certain format of input data. Each block must be wrapped by brackets. Default brackets value is `{ ... }`.<br>
The predetermined formats:

| Symbol | Input format    |
| ------ | :------------- |
| **d**  | Number, decimal number from 0 to 9. |
| **D**  | Any symbol, except decimal number. |
| **W**  | Not an alphabetic symbol. |
| **a**  | Alphabetic symbol, a-Z. |
| **.**  | Corresponds to any symbol (by default) |

The initial value of this property is `nil`.
<br>
<br>
```swift
var maskTemplate: String
```

The text that represents the mask filed with replacing format symbol with template characters. Can be set:

| Characters count                         | Description    |
| :--------------------------------------- | :------------- |
| **1**                                    | This character will be copied in each block and will replace mask format symbol. |
| **Same length as mask without brackets** | Template character will replace mask format symbol in same position. |

The initial value of this property is `*`.
<br>
<br>
```swift
var maskShowTemplate: Bool
```

A Boolean value indicating will be mask template shows after initialization.<br>
The initial value of this property is `false`.

### Configuring mask

```swift
var maskBlockBrackets: [Character]
```

An array with two characters (opening and closing bracket for the bock mask).<br>
The initial values in this array is `{` and `}`.

### Mask object

```swift
var maskObject: [AKMaskFieldBlock]! {get}
```

An array with all blocks mask. Each array value defined as `AKMaskFieldBlock` structure.<br>
The initial value of this property is `nil`.

#### Block `AKMaskFieldBlock` mask

```swift
var index: Int
```

The block index in the mask.
<br>
<br>
```swift
var status: Bool
```

A Boolean value that determines is the block filled in current moment.
<br>
<br>
```swift
var range: Range<Int>
```

The block position in the mask string.
<br>
<br>
```swift
var mask: String
```

The block string (without brackets).
<br>
<br>
```swift
var text: String
```

Entered characters in the block.
<br>
<br>
```swift
var template: String
```

The block template string.
<br>
<br>
```swift
var chars: [AKMaskFieldBlockChars]
```

An array with all characters mask in certain block. Each character value defined as `AKMaskFieldBlockChars` structure.

#### Characters `AKMaskFieldBlockChars` block

```swift
var index: Int
```

The character index in the block.
<br>
<br>
```swift
var status: Bool
```

A Boolean value that determines is the character filled in current moment.
<br>
<br>
```swift
var text: String
```

Entered character.
<br>
<br>
```swift
var range: Range<Int>
```

Character position in the mask string.

### Status of the mask and an user events

```swift
var maskStatus: AKMaskFieldStatus
```

Defines a status of the mask field at the current moment. The field has 3 states and defined as `AKMaskFieldStatus` enumeration type.

```swift
enum AKMaskFieldStatus {
    case Clear
    case Incomplete
    case Complete
}
```

| Status         | Description    |
| :------------- | :------------- |
| **Clear**      | No one character was entered. |
| **Incomplete** | At least one character is not entered. |
| **Complete**   | All characters was entered. |

The initial value of this property is `AKMaskFieldStatus.Clear`.
<br>
<br>
```swift
var maskEvent: AKMaskFieldEvet
```

Defines a user events. The user can make 4 events, all events defined as `AKMaskFieldEvet` enumeration type.

```swift
enum AKMaskFieldEvet {
    case None
    case Insert
    case Delete
    case Replace
}
```

| Event       | Action    |
| :-----------| :------------- |
| **None**    | No one event was detected. |
| **Insert**  | Entering new text. |
| **Delete**  | Deleting text from field. |
| **Replace** | Selecting and replacing or deleting text. |

The initial value of this property is `AKMaskFieldEvet.None`.

### Accessing the Delegate

```swift
weak var maskDelegate: AKMaskFieldDelegate?
```

A mask field delegate responds to editing-related messages from the text field. You can use the delegate to respond to the text entered by the user and to some special commands, such as when the return button is pressed.

## Delegate methods

```swift
optional func maskFieldDidBeginEditing(maskField: AKMaskField)
```

| Parameter     | Description    |
| :------------ | :------------- |
| maskField     | The mask field for which an editing session began. |

Tells the delegate that editing began for the specified mask field.
<br>
<br>
```swift
optional func maskField(maskField: AKMaskField,
 shouldChangeCharacters oldString: String,
                inRange range: NSRange,
      replacementString withString: String)
```

| Parameter     | Description    |
| :------------ | :------------- |
| maskField     | The mask field containing the text. |
| oldString     | The string that will replaced. |
| range         | The range of characters to be replaced. |
| withString    | The replacement string. |

Asks the delegate if the specified text should be changed.

## Tips

### How get entered text without mask

```swift
var enteredText: String = ""
for block in field.maskObject {

    for char in block.chars {
        if char.status { enteredText += String(char.text) }
    }
}

println("Entered text: \(enteredText)")
```

---

Please do not forget to star this repository and follow me.

### Author

Artem Krachulov: [www.artemkrachulov.com](http://www.artemkrachulov.com/), email [artem.krachulov@gmail.com](mailto:artem.krachulov@gmail.com)

### License

Released under the [MIT license](http://www.opensource.org/licenses/MIT)