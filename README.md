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
<img src="https://raw.githubusercontent.com/artemkrachulov/AKMaskField/master/Assete/preview.png" alt="preview.png">
<h2><a id="user-content-usage" class="anchor" href="#usage" aria-hidden="true"><span class="octicon octicon-link"></span></a>Usage</h2>
<p>Include AKMaskField.swift file to your project. Set UITextField as AKMaskField custom class. Define your masks properties:</p>
<p><b>Code:</b></p>
<pre>
self.filed.mask = "{dddd}-{DDDD}-{WaWa}-{aaaa}"
self.filed.maskShow = true
self.filed.maskPlaceholder = "xxxx-xxxx-xxxx-xxxx"

// Set new text property for textField
self.field.text = "5654-3423-5127-4562"
self.card.maskFieldUpdate()
</pre>
<p><b>Storyboard:</b></p>
<pre>
Mask: {dddd}-{DDDD}-{WaWa}-{aaaa}
Mask Show: On
Mask Placeholder: xxxx-xxxx-xxxx-xxxx
</pre>
<h2><a id="user-content-properties" class="anchor" href="#properties" aria-hidden="true"><span class="octicon octicon-link"></span></a>Properties</h2>
<h3><a id="user-content-masks" class="anchor" href="#static-masks" aria-hidden="true"><span class="octicon octicon-link"></span></a>Mask</h3>
<p><code>.mask</code> or <code>Mask</code></p>
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
<h3><a id="user-content-show" class="anchor" href="#static-show" aria-hidden="true"><span class="octicon octicon-link"></span></a>Show</h3>
<p><code>.maskShow</code> or <code>Mask Show</code></p>
<p>Boolean property which define mask view status. Similar as default placeholder actions. Can have 2 states:</p>
<ul class="task-list">
<li><b>On (true)</b> - Mask always visible. Overrides default UITextField placeholder</li>
<li><b>Off (false)</b> - Mask visible if user type text. If mask field don't have any user text field will be empty or show default UITextField placeholder (default)</li>
</ul>
<h3><a id="user-content-placeholder" class="anchor" href="#static-placeholder" aria-hidden="true"><span class="octicon octicon-link"></span></a>Placeholder</h3>
<p><code>.maskPlaceholder</code> or <code>Mask Placeholder</code></p>
<p>String property display text which will see user. Placeholder can be:</p>
<ul class="task-list">
<li><b>1</b> character length. In this case char character will be copied to full mask length. (default "*")
<pre>
self.filed.mask = "{dddd}-{DDDD}-{WaWa}-{aaaa}"
self.filed.maskPlaceholder = "Z"

// Text in mask filed
// ZZZZ-ZZZZ-ZZZZ-ZZZZ
</pre>
</li>
<li><b>Same lenght</b> as mask(without brackets)
<pre>
self.filed.mask = "{dddd}-{DDDD}-{WaWa}-{aaaa}"      // 19 characters  
self.filed.maskPlaceholder = "ABCD-EFGH-IJKL-MNOP"   // 19 characters

// Text in mask filed
// ABCD-EFGH-IJKL-MNOP
</pre>
</li>
</ul>
<h2><a id="user-content-properties" class="anchor" href="#properties" aria-hidden="true"><span class="octicon octicon-link"></span></a>Callback properties</h2>
<h3><a id="user-content-status" class="anchor" href="#static-status" aria-hidden="true"><span class="octicon octicon-link"></span></a>Status</h3>
<p><code>.maskStatus</code></p>
<p>String property return mask status in real time. Mask can have 3 states:</p>
<ul class="task-list">
<li><b>Clear</b> - User not filled any characters block</li>
<li><b>Incomplete</b> - At least 1 character is filled</li>
<li><b>Complete</b> - All characters blocks is filled</li>
</ul>
<h3><a id="user-content-object" class="anchor" href="#static-object" aria-hidden="true"><span class="octicon octicon-link"></span></a>Object</h3>
<p><code>.maskObject</code></p>
<p>Dictionary type contain all mask blocks with properties.</p>
<pre>
[[
  range       : 0..&lt;4,
  mask        : "dddd",
  placeholder : "xxxx",
  status      : false,
  chars: [
    [ range: 0..&lt;1, status: false ],
    [ range: 1..&lt;2, status: false ], 
    [ range: 2..&lt;3, status: false ], 
    [ range: 3..&lt;4, status: false ]
  ]
], 
[ ... ],
[ ... ],
[ ... ]]
</pre>
<h2><a id="user-content-events" class="anchor" href="#events" aria-hidden="true"><span class="octicon octicon-link"></span></a>Events</h2>
<p>You can use AKMaskFieldDelegate protocol to control all mask field events:</p>
<pre>
override func viewDidLoad() {
  super.viewDidLoad()
  // Do any additional setup after loading the view, typically from a nib.

  self.field.events = self
}

func maskFieldDidBeginEditing(maskField: AKMaskField) { 
  // Detect when you place caret into the field
  println("Your mask field \(maskField)")
}

func maskField(maskField: AKMaskField, madeEvent: String, withText oldText: String!, inRange oldTextRange: NSRange, withText newText: String) {

  // Detect any text changing in the field
  println("Your mask field \(maskField)")
  println("Text events \(madeEvent)")      // "Insert", "Replace", "Delete", "Error"
  println("Text \(oldText) and range \(oldTextRange) before event")
  println("Text after event \(newText)")
}

// Event separated by type 
func maskField(maskField: AKMaskField, replaceText oldText: String, inRange oldTextRange: NSRange, withText newText: String) {}
func maskField(maskField: AKMaskField, insertText text: String, inRange range: NSRange) {}
func maskField(maskField: AKMaskField, deleteText text: String, inRange range: NSRange) {}
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
