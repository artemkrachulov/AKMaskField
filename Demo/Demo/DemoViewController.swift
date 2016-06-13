//
//  DemoViewController.swift
//  Demo
//
//  Created by Artem Krachulov
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class DemoViewController: UIViewController {
  
  var programmatically: Bool!
  
  //  MARK: - Outlets
  
  @IBOutlet var indicators: [UIView]!
  @IBOutlet var clipboard: [UILabel]!
  
  @IBOutlet weak var card: AKMaskField? {
    didSet { card?.maskDelegate = self }
  }
  @IBOutlet weak var phone: AKMaskField? {
    didSet { phone?.maskDelegate = self }
  }
  @IBOutlet weak var key: AKMaskField? {
    didSet { key?.maskDelegate = self }
  }
  @IBOutlet weak var license: AKMaskField? {
    didSet { license?.maskDelegate = self }
  }
  
  //  MARK:   Objects programmatically
  
  var cardProgrammatically: AKMaskField? {
    didSet { cardProgrammatically?.maskDelegate = self }
  }
  var phoneProgrammatically: AKMaskField? {
    didSet { phoneProgrammatically?.maskDelegate = self }
  }
  var keyProgrammatically: AKMaskField? {
    didSet { keyProgrammatically?.maskDelegate = self }
  }
  var licenseProgrammatically: AKMaskField? {
    didSet { licenseProgrammatically?.maskDelegate = self }
  }

  //  MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if programmatically! {
      
      card?.removeFromSuperview()
      key?.removeFromSuperview()
      phone?.removeFromSuperview()
      license?.removeFromSuperview()
      
      cardProgrammatically = AKMaskField(frame: CGRectMake(16, 96.5, 315, 30))
      cardProgrammatically?.tag = 0
      cardProgrammatically?.setMask("{dddd}-{dddd}-{dddd}-{dddd}", withMaskTemplate: "ABCD-EFGH-IJKL-MNOP")
      cardProgrammatically!.borderStyle = .RoundedRect
      view.addSubview(cardProgrammatically!)
      
      phoneProgrammatically = AKMaskField(frame: CGRectMake(16, 207.5, 315, 30))
      phoneProgrammatically?.tag = 1
      phoneProgrammatically?.setMask("+38 ({ddd}) {ddd}-{dd}-{dd}", withMaskTemplate: "+38 (___) ___-__-__")
      phoneProgrammatically!.borderStyle = .RoundedRect
      view.addSubview(phoneProgrammatically!)
      
      keyProgrammatically = AKMaskField(frame: CGRectMake(16, 302.5, 315, 30))
      keyProgrammatically?.tag = 2
      keyProgrammatically?.setMask("{aa}/{d} {d} {d}-{ddd}-{dd}", withMaskTemplate: "AA/N N N-NNN-NN")
      keyProgrammatically!.borderStyle = .RoundedRect
      view.addSubview(keyProgrammatically!)
      
      licenseProgrammatically = AKMaskField(frame: CGRectMake(16, 357, 315, 30))
      licenseProgrammatically?.tag = 3
      licenseProgrammatically?.setMask("{.............................}", withMaskTemplate: nil)
      licenseProgrammatically?.placeholder = "past code here"
      licenseProgrammatically!.borderStyle = .RoundedRect
      view.addSubview(licenseProgrammatically!)
    }
  }

  //  MARK:   Actions

  @IBAction func clipboard(sender: UIButton) {
    
    let tag = sender.tag
    let copyText = clipboard[tag].text!
    let message = "Text \"" + copyText + "\" copied to clibboard. Past text to field."
    
    // Copy text to clipboard
    UIPasteboard.generalPasteboard().string = copyText
    
    // Show alert
    let copyAlert = UIAlertController(title: "Clipboard", message: message, preferredStyle: .Alert)
    
    copyAlert.addAction(UIAlertAction(title: "Ok", style: .Default,
      handler: { _ -> Void in
        
        switch tag {
        case 0,1,2:
          self.card?.becomeFirstResponder()
          self.cardProgrammatically?.becomeFirstResponder()
        case 3,4:
          self.phone?.becomeFirstResponder()
          self.phoneProgrammatically?.becomeFirstResponder()
        case 5,6:
          self.key?.becomeFirstResponder()
          self.keyProgrammatically?.becomeFirstResponder()
        case 7:
          self.license?.becomeFirstResponder()
          self.licenseProgrammatically?.becomeFirstResponder()
        default: ()
        }
      }
    ))
    
    presentViewController(copyAlert, animated: true, completion: nil)
  }
  
  @IBAction func clearFields(sender: AnyObject) {
    
    card?.updateText("")
    cardProgrammatically?.updateText("")
    
    phone?.updateText("")
    phoneProgrammatically?.updateText("")
    
    key?.updateText("")
    keyProgrammatically?.updateText("")
    
    license?.updateText("")
    licenseProgrammatically?.updateText("")
  }
}

//  MARK: - AKMaskFieldDelegate

extension DemoViewController: AKMaskFieldDelegate {
  
  func maskFieldDidBeginEditing(maskField: AKMaskField) {
    print("Mask field did begin editing")
  }

  func maskField(maskField: AKMaskField, didChangeCharactersInRange range: NSRange, replacementString string: String, withEvent event: AKMaskFieldEvent) {
    
    // Status
    var statusColor =  UIColor.clearColor()
    
    switch maskField.maskStatus {
    case .Clear:
      statusColor = UIColor.lightGrayColor()
    case .Incomplete:
      statusColor = UIColor.blueColor()
    case .Complete:
      statusColor = UIColor.greenColor()
    }
    
    UIView.animateWithDuration(0.2,
                               delay: 0,
                               options: UIViewAnimationOptions.CurveEaseIn,
                               animations: { () -> Void in
                                self.indicators[maskField.tag].backgroundColor = statusColor
      }, completion: nil
    )
    
    // Event
    var eventColor =  UIColor.redColor().colorWithAlphaComponent(0.2)
    switch event {
    case .Insert:
      eventColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
    case .Replace:
      eventColor = UIColor.brownColor().colorWithAlphaComponent(0.2)
    case .Delete:
      eventColor = UIColor.orangeColor().colorWithAlphaComponent(0.2)
    default: ()
    }
    
    UIView.animateWithDuration(0.05,
                               delay: 0,
                               options: .CurveEaseIn,
                               animations: { () -> Void in
                                maskField.backgroundColor = eventColor
                                
      }
    ) { (Bool) -> Void in
      UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut,
                                 animations: { () -> Void in
                                  
                                  maskField.backgroundColor = UIColor.clearColor()
                                  
        },completion: nil
      )
    }
  }
}