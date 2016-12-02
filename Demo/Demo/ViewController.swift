//
//  ViewController.swift
//  Demo
//
//  Created by Artem Krachulov
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

class ViewController: UIViewController {
    
    //  MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DemoViewController {
            vc.programmatically = segue.identifier == "Programmatically"
            vc.navigationItem.title = segue.identifier
        }
    }
}
