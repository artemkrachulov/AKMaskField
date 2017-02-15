//
//  ViewController.swift
//  AKMaskField
//
//  Created by Artem Krachulov
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit
import AKMaskField

final class ViewController: UIViewController {

    // MARK: Props
    
    private var cardProgrammatically: AKMaskField!
    private var phoneProgrammatically: AKMaskField!
    private var keyProgrammatically: AKMaskField!
    private var licenseProgrammatically: AKMaskField!
    
    private var card: AKMaskField {
        return cardProgrammatically ?? cardStoryboard
    }
    private var phone: AKMaskField {
        return cardProgrammatically ?? cardStoryboard
    }
    private var key: AKMaskField {
        return cardProgrammatically ?? cardStoryboard
    }
    private var license: AKMaskField {
        return cardProgrammatically ?? cardStoryboard
    }
    
    //  MARK: - Connections:
    
    //  MARK: ** Outlets **
    
    @IBOutlet var indicators: [UIView]!
    @IBOutlet var clipboard: [UILabel]!

    @IBOutlet weak var cardStoryboard: AKMaskField!
    @IBOutlet weak var phoneStoryboard: AKMaskField!
    @IBOutlet weak var keyStoryboard: AKMaskField!
    @IBOutlet weak var licenseStoryboard: AKMaskField!

    //  MARK: ** Actions **

    @IBAction func clipboard(_ sender: UIButton) {
        
        let tag = sender.tag
        let copyText = clipboard[tag].text!
        let message = "Text \"" + copyText + "\" copied to clibboard. Past text to field."
        
        // Copy text to clipboard
        
        UIPasteboard.general.string = copyText
        
        // Alert
        
        let copyAlert = UIAlertController(title: "Clipboard", message: message, preferredStyle: .alert)
        copyAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ -> Void in
            
            switch tag {
            case 0,1,2: self.card.becomeFirstResponder()
            case 3,4:   self.phone.becomeFirstResponder()
            case 5,6:   self.key.becomeFirstResponder()
            case 7:     self.license.becomeFirstResponder()
            default: ()
            }
        }))
        
        present(copyAlert, animated: true, completion: nil)
    }
    
    @IBAction func clearFields(_ sender: AnyObject) {
        card.text = nil
        phone.text = nil
        key.text = nil
        license.text = nil
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()        

        // Programmatically initialization
        
        /*
        cardProgrammatically = AKMaskField(frame: CGRect(x: 16, y: 96.5, width: 315, height: 30))
        cardProgrammatically?.tag = 0
        cardProgrammatically?.setMask("{dddd}-{dddd}-{dddd}-{dddd}", withMaskTemplate: "ABCD-EFGH-IJKL-MNOP")
        cardProgrammatically!.borderStyle = .roundedRect
        view.addSubview(cardProgrammatically!)        
         
        phoneProgrammatically = AKMaskField(frame: CGRect(x: 16, y: 207.5, width: 315, height: 30))
        phoneProgrammatically?.tag = 1
        phoneProgrammatically?.setMask("+38 ({ddd}) {ddd}-{dd}-{dd}", withMaskTemplate: "+38 (___) ___-__-__")
        phoneProgrammatically!.borderStyle = .roundedRect
        view.addSubview(phoneProgrammatically!)
        
        keyProgrammatically = AKMaskField(frame: CGRect(x: 16, y: 302.5, width: 315, height: 30))
        keyProgrammatically?.tag = 2
        keyProgrammatically?.setMask("{aa}/{d} {d} {d}-{ddd}-{dd}", withMaskTemplate: "CC/N N N-NNN-NNs")
        keyProgrammatically!.borderStyle = .roundedRect
        view.addSubview(keyProgrammatically!)
        
        licenseProgrammatically = AKMaskField(frame: CGRect(x: 16, y: 357, width: 315, height: 30))
        licenseProgrammatically?.tag = 3
        licenseProgrammatically?.setMask("{.............................}", withMaskTemplate: nil)
        licenseProgrammatically?.placeholder = "past code here"
        licenseProgrammatically!.borderStyle = .roundedRect
        view.addSubview(licenseProgrammatically!)
        */
        
        card.maskDelegate = self
        phone.maskDelegate = self
        key.maskDelegate = self
        license.maskDelegate = self
    }
}

//  MARK: - AKMaskFieldDelegate

extension ViewController: AKMaskFieldDelegate {
    
    func maskField(_ maskField: AKMaskField, didChangedWithEvent event: AKMaskFieldEvent) {
        
        var statusColor, eventColor: UIColor!
        
        // Status
        
        switch maskField.maskStatus {
        case .clear      : statusColor = UIColor.lightGray
        case .incomplete : statusColor = UIColor.blue
        case .complete   : statusColor = UIColor.green
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { () -> Void in
            self.indicators[maskField.tag].backgroundColor = statusColor
        })
        
        // Event
        
        switch event {
        case .insert  : eventColor = UIColor.lightGray
        case .replace : eventColor = UIColor.brown
        case .delete  : eventColor = UIColor.orange
        case .error   : eventColor = UIColor.red
        }
        
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseIn, animations: { () -> Void in
            
            maskField.backgroundColor = eventColor.withAlphaComponent(0.2)
        }) { (Bool) -> Void in
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                
                maskField.backgroundColor = UIColor.clear
            })
        }
    }
}

