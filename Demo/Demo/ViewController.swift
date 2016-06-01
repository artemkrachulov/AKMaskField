//
//  ViewController.swift
//  AKTextFieldMask
//  GitHub: https://github.com/artemkrachulov/AKMaskField
//
//  Created by Krachulov Artem
//  Copyright (c) 2015 Krachulov Artem. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class ViewController: UIViewController {
	
	

    
    override func viewDidLoad() {
        super.viewDidLoad()
			

    }
    

	
	
	@IBAction func changeAction(sender: UIBarButtonItem) {
		

		
	}
	

}

// MARK: - AKMaskFieldDelegate
//         _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

extension ViewController: AKMaskFieldDelegate {
    
    func maskField(maskField: AKMaskField, shouldChangeCharacters oldString: String, inRange range: NSRange, replacementString withString: String) {
        
        // Status animation
        var statusColor =  UIColor.clearColor()
        
        switch maskField.maskStatus {
            case .Clear:
                statusColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
            case .Incomplete:
                statusColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
            case .Complete:
                statusColor = UIColor(red: 0/255, green: 219/255, blue: 86/255, alpha: 1.0)
        }
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
            
//                self.indicators[maskField.tag].backgroundColor = statusColor
							
            },
            completion: nil
        )
        
        // Event animation
        var eventColor =  UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 0.5)
        switch maskField.maskEvent {
            case .Insert:
                eventColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
            case .Replace:
                eventColor = UIColor(red: 140/255, green: 190/255, blue: 178/255, alpha: 0.5)
            case .Delete:
                eventColor = UIColor(red: 243/255, green: 181/255, blue: 98/255, alpha: 0.5)
            default: ()
        }
        
        UIView.animateWithDuration(0.05, delay: 0, options: .CurveEaseIn,
            animations: { () -> Void in
            
                maskField.backgroundColor = eventColor
            
            }
        ) { (Bool) -> Void in
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut,
                animations: { () -> Void in
                
                    maskField.backgroundColor = UIColor.clearColor()
                
                },
                completion: nil
            )
        }
    }
}