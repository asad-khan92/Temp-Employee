//
//  PhoneNumberVerificationController.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/13/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import PKHUD

class PhoneNumberVerificationController: UIViewController {
    
    
    @IBOutlet var verificationCodeFields: [UITextField]!
    
    @IBOutlet weak var resendCodeLabel: UILabel!
    @IBOutlet weak var resendCodeButton: UIButton!
    
    var resendTimeInSec = 120
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.startResendTimer()
        _ = verificationCodeFields.map{$0.delegate = self}
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object:verificationCodeFields[0])
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object:verificationCodeFields[1])
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object:verificationCodeFields[2])
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object:verificationCodeFields[3])
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        let code:String! = verificationCodeFields.flatMap{$0.text!}.reduce("",+)
        
        if Int(code!) == Defaults[.verificationCode]{
            
            return true
        }else{
            return false
            HUD.flash(.labeledError(title: "Invalid code", subtitle: "try again"), delay: 3.0)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func startResendTimer(){
        
        self.timer = Timer.init(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: RunLoopMode.commonModes)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        
        let code:String! = verificationCodeFields.flatMap{$0.text!}.reduce("",+)
        
        if Int(code!) == Defaults[.verificationCode]{
            
            self.setVerificationStatus()
        }else{
            
            HUD.flash(.labeledError(title: "Invalid code", subtitle: "try again"), delay: 3.0)
        }
    }
    
    func updateTimer(){
        if resendTimeInSec <= 1 {
            self.resendCodeLabel.text = "RESEND CODE"
            self.resendCodeLabel.isEnabled = true
            self.resendCodeButton.isEnabled = true
            self.timer?.invalidate()
        }else{
            self.setResendButtonTime()
        }
    }
    
    func setResendButtonTime(){
        
        resendTimeInSec = resendTimeInSec - 1
        self.resendCodeLabel.text = "RESEND CODE \(remainingTime())"
        self.resendCodeLabel.isEnabled = false
        self.resendCodeButton.isEnabled = false
    }
    
    @IBAction func resendCodePressed(_ sender: Any) {
        self.resendCodeButton.isEnabled = false
        resendTimeInSec = 120
        self.setResendButtonTime()
        self.startResendTimer()
        self.resendCode()
    }
    
    func remainingTime()->String{
        
        let quotient  = resendTimeInSec / 60
        let remainder = resendTimeInSec % 60
        return String(format: "%02d : %02d", arguments: [quotient,remainder])
    }
    
    func moveToNextController()  {
        
       let storyboard = UIStoryboard(name: "Registration", bundle: nil)

        let licenceVC : AccountCreationSuccessController = storyboard.instantiateViewController()

        //licenceVC.licenceSelected = Defaults[.licenceHeldByEmployee]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: true, completion: nil)
        appDelegate.navigationController?.pushViewController(licenceVC, animated: true)
        
    }
}
extension PhoneNumberVerificationController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ notification: UITextField) {
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == ""{
            return true
        }
        if textField.text!.length > 0{
            return false
        }
        
        
        return true
    }
    
    func textFieldTextDidChange(_ notification: Notification){
        
        let textField = notification.object as! UITextField
        let nextFieldIndex = verificationCodeFields.index(of: textField)! + 1
        if nextFieldIndex < verificationCodeFields.count && textField.text!.length > 0 {
            textField.resignFirstResponder()
            verificationCodeFields[nextFieldIndex].becomeFirstResponder()
        }else if nextFieldIndex == verificationCodeFields.count{
            
            textField.resignFirstResponder()
        }
        
    }
}
/// MARK :- NETWORKING
extension PhoneNumberVerificationController{
    
    func resendCode(){
        
        HUD.show(.progress, onView: self.view)
        NumberVerificationService().resendVerificationCode(employerID: Defaults[.employerID]!) { (result) in
            HUD.hide()
            switch result{

            case .Success(let code):
                Defaults[.verificationCode] = (code.verificationCode?.intValue)!

            case .Failure(let error):
                print(error)
            }
        }
        
    }
    
    func setVerificationStatus(){
        
        NumberVerificationService().setUserNumberVerified(employerID:Defaults[.employerID]! , completionHandler: { (result) in
            switch result{
                
            case .Success(let success):
               // Defaults[.hasUserVerifiedPhoneNumber] = true
                self.moveToNextController()
                print(success)
            case .Failure(let error):
                print(error)
            }
        })
        
        
    }
}
