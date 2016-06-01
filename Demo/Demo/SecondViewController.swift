//
//  SecondViewController.swift
//  Demo
//
//  Created by Krachulov Artem  on 3/19/16.
//  Copyright © 2016 Artem Krachulov. All rights reserved.
//

import UIKit

class SecondViewController: FirstViewController {


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		print(view)
		card = AKMaskField(frame: CGRectMake(16,97, CGRectGetWidth(view.frame) - 32 ,30))
		card.borderStyle = .RoundedRect
		
		view.addSubview(card)
		
		
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
