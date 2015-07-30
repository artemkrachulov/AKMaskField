# AKMaskField

<p>AKMaskField is Swift plugin.</p>
<p>AKMaskField allows a user to more easily enter fixed width input where you would like them to enter the data in a certain format (dates,phone numbers, etc)</p>
<p><b>Features:</b></p>
<ul class="task-list">
<li>easy to use from code or storyboard</li>
<li>smart mask placeholder</li>
<li>mask field status callbacks</li>
<li>lots of delegates</li>
<li>regex-mask support</li>
<li>dynamic-mask support</li>
<li>fast field processing</li>
<li>smart copy/past text features</li>
</ul>

<h2><a id="user-content-demo" class="anchor" href="#demo" aria-hidden="true"><span class="octicon octicon-link"></span></a>Demo</h2>

<img src="https://raw.githubusercontent.com/artemkrachulov/AKMaskField/master/Assets/preview.png" alt="preview.png">

<h2><a id="user-content-usage" class="anchor" href="#usage" aria-hidden="true"><span class="octicon octicon-link"></span></a>Usage</h2>

<p>Include AKMaskField.swift file to your project. Set UITextField as AKMaskField custom class. Define your masks properties:</p>
<p><b>Code:</b></p>
<pre>
self.field.mask = "{dddd}-{DDDD}-{WaWa}-{aaaa}"
self.field.maskShowTemplate = true
self.field.maskTemplate = "xxxx-xxxx-xxxx-xxxx"

// Set new text property for textField
self.field.text = "5654-3423-5127-4562"
</pre>
<p><b>Storyboard:</b></p>
<pre>
Mask: {dddd}-{DDDD}-{WaWa}-{aaaa}
Mask Show Template: On
Mask Template: xxxx-xxxx-xxxx-xxxx
</pre>
<h2><a id="user-content-properties" class="anchor" href="#properties" aria-hidden="true"><span class="octicon octicon-link"></span></a>Properties</h2>
<h3><a id="user-content-mask" class="anchor" href="#static-mask" aria-hidden="true"><span class="octicon octicon-link"></span></a>Mask</h3>
<p><code>.mask</code> or <code>mask</code> key path</p>
<p>String property which define whole mask text. Text contain blocks with characters and any text outside blocks. All mask blocks must be defined in brackets <code>{</code> ... <code>}</code>.</p>
<p>Example:</p>
<pre>{dddd}-{ddddd}-{dddd}-{dddd}</pre>
<p>Each character may be validated by type. The following mask definitions are predefined:</p>
<ul class="task-list">
<li><b>d</b> - Number, Decimal Digit</li>
<li><b>D</b> - Match any character that is not a decimal digit</li>
<li><b>W</b> - Match a non-word character</li>
<li><b>a</b> - Match alphabet</li>
<li><b>.</b> - Match any character (default)</li>
</ul>
<p>Example:</p>
<pre>{dddd}-{DDDD}-{WaWa}-{aaaa}</pre>
<h3><a id="user-content-show" class="anchor" href="#static-show" aria-hidden="true"><span class="octicon octicon-link"></span></a>Show Template</h3>
<p><code>.maskShowTemplate</code> or <code>maskShowTemplate</code> key path</p>
<p>Boolean property which define mask view template. Similar as default placeholder actions. Can have 2 states:</p>
<ul class="task-list">
<li><b>On (true)</b> - Mask always visible. Overrides default UITextField placeholder</li>
<li><b>Off (false)</b> - Mask visible if user type text. If mask field don't have any user text field will be empty or show default UITextField placeholder (default)</li>
</ul>
<h3><a id="user-content-template" class="anchor" href="#static-template" aria-hidden="true"><span class="octicon octicon-link"></span></a>Template</h3>
<p><code>.maskTemplate</code> or <code>maskTemplate</code> key path</p>
<p>String property display text which will see user. Template can be:</p>
<ul class="task-list">
<li><b>1</b> character length. In this case char character will be copied to full mask length. (default "*")
<pre>
self.field.mask = "{dddd}-{DDDD}-{WaWa}-{aaaa}"
self.field.maskTemplate = "Z"

// Text in mask filed
// ZZZZ-ZZZZ-ZZZZ-ZZZZ
</pre>
</li>
<li><b>Same lenght</b> as mask(without brackets)
<pre>
self.field.mask = "{dddd}-{DDDD}-{WaWa}-{aaaa}"      // 19 characters
self.field.maskTemplate = "ABCD-EFGH-IJKL-MNOP"   // 19 characters

// Text in mask filed
// ABCD-EFGH-IJKL-MNOP
</pre>
</li>
</ul>

<h3><a id="user-content-object" class="anchor" href="#static-object" aria-hidden="true"><span class="octicon octicon-link"></span></a>Mask Object</h3>
<p><code>.maskObject</code></p>
<p>Array type <code>[AKMaskFieldBlock]</code>, contain all mask blocks and characters.</p>

<pre>
let block = self.field.maskObject[0]     // get first block

block.index   // Int
block.status   // Bool
block.range   // Range&lt;Int&gt;
block.mask   // String
block.template   // String
block.chars   // [AKMaskFieldBlockChars]

let chars = block.chars    // get all characters in block

chars.status: Bool
chars.range: Range&lt;Int&gt;
</pre>

<h2><a id="user-content-properties" class="anchor" href="#properties" aria-hidden="true"><span class="octicon octicon-link"></span></a>Callback properties</h2>

<h3><a id="user-content-status" class="anchor" href="#static-status" aria-hidden="true"><span class="octicon octicon-link"></span></a>Status</h3>
<p><code>.maskStatus</code></p>
<p>Enum property return mask status in real time. Mask can have 3 states:</p>
<ul class="task-list">
<li><b>.Clear</b> - User not filled any characters block</li>
<li><b>.Incomplete</b> - At least 1 character is filled</li>
<li><b>.Complete</b> - All characters blocks is filled</li>
</ul>

<h3><a id="user-content-status" class="anchor" href="#static-status" aria-hidden="true"><span class="octicon octicon-link"></span></a>Events</h3>
<p><code>.maskEvent</code></p>
<p>Event property return mask current event in real time. Events can can be:</p>
<ul class="task-list">
<li><b>.None</b></li>
<li><b>.Insert</b></li>
<li><b>.Delete</b></li>
<li><b>.Replace</b></li>
</ul>

<h2><a id="user-content-events" class="anchor" href="#events" aria-hidden="true"><span class="octicon octicon-link"></span></a>Events</h2>
<p>You can use AKMaskFieldDelegate protocol to control all mask changes:</p>
<pre>
override func viewDidLoad() {
  super.viewDidLoad()
  // Do any additional setup after loading the view, typically from a nib.

  self.field.maskDelegate = self
}

func maskFieldDidBeginEditing(maskField: AKMaskField) {
  // Detect when you place caret into the field
  println("Your mask field \(maskField)")
}

func maskField(maskField: AKMaskField, shouldChangeCharacters oldString: String, InRange range: NSRange, replacementString withString: String) {

  // Detect any text changing in the field
  println("Your mask field \(maskField)")
  println("Range: \(maskField.range)")
  println("Text before: \(maskField.oldString)")
  println("Text after: \(maskField.withString)")
}
</pre>
<h2><a id="user-content-delegates" class="anchor" href="#delegates" aria-hidden="true"><span class="octicon octicon-link"></span></a>Delegates</h2>
<p>We use 2 delegate methods from UITextFieldDelegate in our class AKMaskField. To avoid problems with mask, duplicate mask methods in UITextFieldDelegate methods:</p>
<pre>
func textFieldDidBeginEditing(textField: UITextField) {
  self.card.maskFieldDidBeginEditing(textField)
}
func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
  return self.maskField(textField, shouldChangeCharactersInRange: range, replacementString: string)
}
</pre>
<h2><a id="user-content-author" class="anchor" href="#author" aria-hidden="true"><span class="octicon octicon-link"></span></a>Author</h2>
<p>Artem Krachulov, <a href="mailto:artem.krachulov@gmail.com">artem.krachulov@gmail.com</a></p>
<h2><a id="user-content-license" class="anchor" href="#license" aria-hidden="true"><span class="octicon octicon-link"></span></a>License</h2>
<p>Released under the <a href="http://www.opensource.org/licenses/MIT">MIT license</a>.</p>
