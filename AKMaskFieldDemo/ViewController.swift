//
//  ViewController.swift
//  AKTextFieldMask
//
//  Created by Krachulov Artem  on 12/24/14.
//  Copyright (c) 2014 The Krachulovs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, AKMaskFieldDelegate {
    
    @IBOutlet weak var card: AKMaskField!
    @IBOutlet weak var phone: AKMaskField!
    @IBOutlet weak var key: AKMaskField!
    @IBOutlet weak var license: AKMaskField!
    
    @IBOutlet var indicators: [UIView]!
    @IBOutlet var clipboard: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // delegates
        self.card.maskDelegate = self
        self.phone.maskDelegate = self
        self.key.maskDelegate = self
        self.license.maskDelegate = self
        
        // Draw indicators
        for indicator in indicators {
            indicator.layer.cornerRadius = 10
        }
    }
    
    @IBAction func clipboard(sender: UIButton) {
        
        let tag         = sender.tag
        let copyText    = self.clipboard[tag].text!
        let message     = "Text \"" + copyText + "\" copied to clibboard. Past text to field."
        
        // Copy text to clipboard
        UIPasteboard.generalPasteboard().string = copyText
        
        // Show a;ert
        let copyAlert = UIAlertController(
            title:          "Clipboard",
            message:        message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        copyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { _ -> Void in
            
            switch tag {
                case 0,1,2:
                    self.card.becomeFirstResponder()
                case 3,4,5:
                    self.phone.becomeFirstResponder()
                case 6,7:
                    self.key.becomeFirstResponder()
                case 8:
                    self.license.becomeFirstResponder()
                default:
                    println("Tag out of range")
            }
            
        }))
        presentViewController(copyAlert, animated: true, completion: nil)
    }

    // Hide on click out the field
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {        
        self.card.resignFirstResponder()
        self.phone.resignFirstResponder()
        self.key.resignFirstResponder()
        self.license.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    @IBAction func clearFields(sender: AnyObject) {
        card.text = ""
        phone.text = ""
        key.text = ""
        license.text = ""
    }
    
    /*
    -------------------------------
    // MARK: Delegates
    -------------------------------
    */
    func maskField(maskField: AKMaskField, shouldChangeCharacters oldString: String, inRange range: NSRange, replacementString withString: String) {
    
        // Status animation
        var statusColor: UIColor?
        switch maskField.maskStatus {
        case .Clear:
            statusColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
        case .Incomplete:
            statusColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        case .Complete:
            statusColor = UIColor(red: 0/255, green: 219/255, blue: 86/255, alpha: 1.0)
        default:
            statusColor = UIColor.clearColor()
        }
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.indicators[maskField.tag].backgroundColor = statusColor
            
            }, completion: nil)
        
        // Event animation
        
        var eventColor: UIColor?
        switch maskField.maskEvent {
            case .Insert:
                eventColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
            case .Replace:
                eventColor = UIColor(red: 140/255, green: 190/255, blue: 178/255, alpha: 0.5)
            case .Delete:
                eventColor = UIColor(red: 243/255, green: 181/255, blue: 98/255, alpha: 0.5)
            default:
                eventColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 0.5)
        }
        
        UIView.animateWithDuration(0.05, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            maskField.backgroundColor = eventColor
            
            }) { (Bool) -> Void in
                
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    
                    maskField.backgroundColor = UIColor.clearColor()
                    
                }, completion: nil)
        }
    }
}

