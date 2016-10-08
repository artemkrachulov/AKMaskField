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
    }
  }

  //  MARK:   Actions

  @IBAction func clipboard(_ sender: UIButton) {
    
    let tag = sender.tag
    let copyText = clipboard[tag].text!
    let message = "Text \"" + copyText + "\" copied to clibboard. Past text to field."
    
    // Copy text to clipboard
    UIPasteboard.general.string = copyText
    
    // Show alert
    let copyAlert = UIAlertController(title: "Clipboard", message: message, preferredStyle: .alert)
    
    copyAlert.addAction(UIAlertAction(title: "Ok", style: .default,
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
    
    present(copyAlert, animated: true, completion: nil)
  }
  
  @IBAction func clearFields(_ sender: AnyObject) {
    
    card?.text = nil
    cardProgrammatically?.text = nil
    
    phone?.text = nil
    phoneProgrammatically?.text = nil
    
    key?.text = nil
    keyProgrammatically?.text = nil
    
    license?.text = nil
    licenseProgrammatically?.text = nil
  }
}

//  MARK: - AKMaskFieldDelegate

extension DemoViewController: AKMaskFieldDelegate {
  
  func maskField(_ maskField: AKMaskField, didChangedWithEvent event: AKMaskFieldEvent) {
    
    print("didChangedWithEvent \(maskField.text)")
    
    var statusColor, eventColor: UIColor!
    
    // Status
    
    switch maskField.maskStatus {
    case .clear      : statusColor = UIColor.lightGray
    case .incomplete : statusColor = UIColor.blue
    case .complete   : statusColor = UIColor.green
    }
    
    UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn,
                               animations: { () -> Void in
                                self.indicators[maskField.tag].backgroundColor = statusColor
      }, completion: nil)
    
    // Event
    
    switch event {
    case .insert  : eventColor = UIColor.lightGray.withAlphaComponent(0.2)
    case .replace : eventColor = UIColor.brown.withAlphaComponent(0.2)
    case .delete  : eventColor = UIColor.orange.withAlphaComponent(0.2)
    case .error   : eventColor = UIColor.red.withAlphaComponent(0.2)
    }
    
    UIView.animate(withDuration: 0.05, delay: 0, options: UIViewAnimationOptions.curveEaseIn,
                               animations: { () -> Void in
                                maskField.backgroundColor = eventColor
      }
    ) { (Bool) -> Void in
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut,
                                 animations: { () -> Void in
                                  maskField.backgroundColor = UIColor.clear
        },completion: nil)
    }
  }
  
  func maskFieldDidBeginEditing(_ maskField: AKMaskField) {
    print("maskFieldDidBeginEditing")
  }
  

  func maskFieldDidEndEditing(_ maskField: AKMaskField) {
      print("maskFieldDidEndEditing")
  }

  func maskFieldShouldReturn(_ maskField: AKMaskField) -> Bool {
    return true
  }
  
  func maskField(_ maskField: AKMaskField, shouldChangeBlock block: AKMaskFieldBlock, inRange range: inout NSRange, replacementString string: inout String) -> Bool {
    return true
  }
}
