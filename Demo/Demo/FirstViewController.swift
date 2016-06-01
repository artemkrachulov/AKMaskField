//
//  FirstViewController.swift
//  Demo
//
//  Created by Krachulov Artem  on 3/19/16.
//  Copyright © 2016 Artem Krachulov. All rights reserved.
//

import UIKit

class FirstViewController: ViewController {
	
	@IBOutlet var indicators: [UIView]!
	
	
	@IBOutlet var infoIndicators: [UIView]!
	
	
	
	
	@IBOutlet weak var infoView: UIView!  {
		didSet {
			if let view = UIView.instanceFromNib("InfoView", owner: self, bundle: nil) {
				
				view.frame = infoView.bounds
				view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
				
				infoView.addSubview(view)
				infoView.removeConstraint(infoView.constraints.first!)
			}
			
		}
	}
	
	

	
	
	
	@IBOutlet weak var card: AKMaskField!
	@IBOutlet weak var phone: AKMaskField!
	@IBOutlet weak var key: AKMaskField!
	@IBOutlet weak var license: AKMaskField!
	
//	@IBOutlet var indicators: [UIView]!
	@IBOutlet var clipboard: [UILabel]!
	
	@IBAction func clipboard(sender: UIButton) {
		
		let tag = sender.tag
		let copyText = clipboard[tag].text!
		let message = "Text \"" + copyText + "\" copied to clibboard. Past text to field."
		
		// Copy text to clipboard
		UIPasteboard.generalPasteboard().string = copyText
		
		// Show a;ert
		let copyAlert = UIAlertController(title: "Clipboard", message: message, preferredStyle: .Alert)
		
		copyAlert.addAction(UIAlertAction(title: "Ok", style: .Default,
			handler: { _ -> Void in
				
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
					print("Tag out of range")
				}
				
			}
			))
		
		presentViewController(copyAlert, animated: true, completion: nil)
	}
	
	// Hide on click out the field
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		/*card.resignFirstResponder()
		phone.resignFirstResponder()
		key.resignFirstResponder()
		license.resignFirstResponder()
		view.endEditing(true)*/
	}
	
	@IBAction func clearFields(sender: AnyObject) {
		card.text = ""
		phone.text = ""
		key.text = ""
		license.text = ""
	}
	
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
			
			// delegates
			/*
			card.maskDelegate = self
			phone.maskDelegate = self
			key.maskDelegate = self
			license.maskDelegate = self
			*/
			// Draw indicators
			
			if indicators != nil {
				for indicator in indicators {
					indicator.layer.cornerRadius = indicator.frame.size.width / 2
				}
			}
			
			if infoIndicators != nil {
				for indicator in infoIndicators {
					indicator.layer.cornerRadius = indicator.frame.size.width / 2
				}
			}
			
			
			
	
			
			
			//			 card.text = "1234123412341234"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
