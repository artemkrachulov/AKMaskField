AKMaskField is Swift plugin.

AKMaskField allows the user to enter easily data in the fixed quantity and in certain format (credit cards, telephone numbers, dates, etc.). The developer needs to adjust a format of a mask and a template. The mask consists of symbols and blocks. Each block consists of symbols of a certain type (number, letter, symbol). The template in turn represents a mask with hidden symbols in each block.

**Main features:**

* easy in use
* possibility to setup input field from a code or Settings Panel
* smart template
* the status and action callbacks
* support of dynamic change of a mask
* fast processing of a input field
* smart user input actions: to copy / insert

**Preview**

![Demp](https://raw.githubusercontent.com/artemkrachulov/AKMaskField/master/Assets/preview.png)

## Usage

Add the _AKMaskField.swift_ file to the project (To copy the file it has to be chosen). Create a field of the class _UITextField_ and specify to it the class _AKMaskField_ in the Inspector / Accessory Panel. Attributes or in a code specify necessary attributes in a tab:

**Attributes tab**

```text
Mask: {dddd}-{dddd}-{dddd}-{dddd}
Mask Template: xxxx-xxxx-xxxx-xxxx
Mask Show Template: On

// Input field
xxxx-xxxx-xxxx-xxxx

// Default text attributes settings
Text: 0123

// Input field
0123-xxxx-xxxx-xxxx
```

**The code**

```text
field.mask = "{dddd}-{dddd}-{dddd}-{dddd}"
field.maskTemplate = "xxxx-xxxx-xxxx-xxxx"
field.maskShowTemplate = true

// Input field
xxxx-xxxx-xxxx-xxxx

// Default text attributes settings
field.text = 0123

// Input field
0123-xxxx-xxxx-xxxx
```

## Properties

### Mask

`.mask` property / _mask_ key path / **Mask** attribute

**Type**: String

**Access**: get set

**Default value**: __*__

Defines a type of a mask. A String contains blocks with symbols separated by any string out of blocks. Open and close each block a special symbol.

Symbols in the block define certain type of data. The predetermined types:

* **d** - Number, decimal number from 0 to 9
* **D** - Any symbol, except decimal number
* **W** - Not an alphabetic symbol
* **a** - Alphabetic symbol, a-Z
* **.** - Corresponds to any symbol (by default)

Example:

```text
{dddd}-{DDDD}-{WaWa}-{aaaa}
```

### Template

`.maskTemplate` property / _maskTemplate_ key path / **Mask Template** attribute

**Type**: String

**Access**: get set

**Default value**: __*__

Text template with the hidden symbols of a mask which is seen by the user. Can be in a look:

* **1 character**

  In this case the symbol will be copied in compliance of length of each block of a mask.

Example:

```text
// Mask
{dddd}-{DDDD}-{WaWa}-{aaaa}

// Template
Z

// Input field
ZZZZ-ZZZZ-ZZZZ-ZZZZ
```

* **Any characters**

  In this case the quantity of characters of a template has to be equal to quantity of characters of a mask without brackets.

Example:

```text
// Mask
// 19 characters
{dddd}-{DDDD}-{WaWa}-{aaaa}

// Template
// 19 characters
ABCD-EFGH-IJKL-MNOP

// Input field
ABCD-EFGH-IJKL-MNOP
```

### Visible mask tempalte

`.maskShowTemplate` property / _maskShowTemplate_ key path / **Mask Show Template** attribute

**Type**: Bool

**Access**: get set

**Default value**: false (Default value)

Вefine will a user see a template if the field doesn't contain the entered character and has the status the "Clear" field. Can have 2 states:

* **On (true)** - The template is visible always. Replaces field placeholder.
* **Off (false)** - The template is displayed if the field contains the entered symbols. If the field has no the symbols entered by the user, standard placeholder of a field will be displayed.

### Block brackets

`.maskBlockBrackets` property

**Type**: Array

**Access**: get set

**Default value**: `{` and `}`

Two characters (open and close) that can be changed in the code.

Example:

```swift
// Brackets
field.maskBlockBrackets = ["[", "]"]

// Mask
field.mask = [dddd]-[DDDD]-[WaWa]-[aaaa]
```

### Mask object

`.maskObject` property

**Type**: Array

**Access**: get

**Default value**: Empty attay

Contain all information about mask blocks.

Example:

```swift
// Get first block
let block = self.field.maskObject[0]

print("Block index in the mask \(block.index)") // Int
print("The block is filled or isn't filled: \(block.status)") // true - filled, false - isn't filled
print("The block position in a mask: \(block.range)") // Range<Int>
print("Block mask: \(block.mask)") // String
print("Block template: \(block.template)") // String
print("A characters inside the block: \(block.chars)") // Array<AKMaskFieldBlockChars>

// Get first character
let char = block.chars[0]

print("A character is filled or isn't filled : \(char.status)") // true - filled, false - isn't filled
print("A character position in a mask: \(char.range)") // Range<Int>
```

### Mask status

`.maskStatus` property

**Type**: Enum

**Access**: get

**Default value**: `.Clear` - Empty

Define a condition of a field at the moment. The field has 3 states:

* **.Clear** - Empty (pure), isn't present the filled character
* **.Incomplete** - isn't filled at least one character is entered
* **.Complete** - Filled all character are entered

### User events

`.maskEvent` property

**Type**: Enum

**Access**: get

**Default value**: `.None`

Define a user events. The user can make 4 events:

* **.None** - Not events
* **.Insert** - Enter
* **.Delete** - Delete
* **.Replace** - Select / Enter

### Delegates

`.maskDelegate` property

Define an event which the user carries out with the field. Optional methods. Methods:

* maskFieldDidBeginEditing(maskField: AKMaskField)

  Called when the cursor is placed in the field

* maskField(maskField: AKMaskField, shouldChangeCharacters oldString: String, InRange range: NSRange, replacementString withString: String)

  Called when the user make any event

Example:

```swift
override func viewDidLoad() {
  super.viewDidLoad()

  field.maskDelegate = self
}

// Delegate methods
func maskFieldDidBeginEditing(maskField: AKMaskField) {
    print("Объект класса: \(maskField)")
}

func maskField(maskField: AKMaskField, shouldChangeCharacters oldString: String, InRange range: NSRange, replacementString withString: String) {
    print("Mask object: \(maskField)")
    print("The text before an event: \(maskField.oldString)")
    print("Range of text before event: \(maskField.range)")
    print("The text after an event: \(maskField.withString)")
    print("A field status after an event: \(maskField.maskStatus)")
    print("An event: \(maskField.maskEvent)")
}
```

### Author

Artem Krachulov: [website](http://www.artemkrachulov.com/), [artem.krachulov@gmail.com](artem.krachulov@gmail.com)

### License

Released under the [MIT license](http://www.opensource.org/licenses/MIT)