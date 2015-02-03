//
//  ViewController.swift
//  AKTextFieldMask
//
//  Created by Krachulov Artem  on 12/24/14.
//  Copyright (c) 2014 The Krachulovs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, AKMaskFieldDelegate {
    
    
    @IBOutlet var card: AKMaskField!

    
    @IBOutlet var indicators: [UIView]!
    @IBOutlet var clipboard: [UILabel]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // delegates
        self.card.events = self
        
        // Draw indicators
        for indicator in indicators {
            indicator.layer.cornerRadius    = 10
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
                default:
                    println("Tag out of range")
            }
            
        }))
        presentViewController(copyAlert, animated: true, completion: nil)
    }

    // Hide on click out the field
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.card.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    /*
    -------------------------------
    // MARK: Delegates
    -------------------------------
    */    
    func maskFieldDidBeginEditing(maskField: AKMaskField) {
        println(maskField)
    }
    func maskField(maskField: AKMaskField, madeEvent: String, withText oldText: String!, inRange oldTextRange: NSRange, withText newText: String) {
        
        // Status animation
        var statusColor: UIColor?
        switch maskField.maskStatus {
        case "Clear":
            statusColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
        case "Incomplete":
            statusColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        case "Complete":
            statusColor = UIColor(red: 0/255, green: 219/255, blue: 86/255, alpha: 1.0)
        default:
            statusColor = UIColor.clearColor()
        }
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.indicators[maskField.tag].backgroundColor = statusColor
            
            }, completion: nil)
        
        // Event animation
        var eventColor: UIColor?
        switch madeEvent {
        case "Insert":
            eventColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
        case "Replace":
            eventColor = UIColor(red: 140/255, green: 190/255, blue: 178/255, alpha: 0.5)
        case "Delete":
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
        
        println(maskField.maskObject)
    }
    func maskField(maskField: AKMaskField, replaceText oldText: String, inRange oldTextRange: NSRange, withText newText: String) {
        println(maskField, oldText, oldTextRange, newText)
    }
    func maskField(maskField: AKMaskField, insertText text: String, inRange range: NSRange) {
        println(maskField, text, range)
    }
    func maskField(maskField: AKMaskField, deleteText text: String, inRange range: NSRange) {
        println(maskField, text, range)
    }
}

