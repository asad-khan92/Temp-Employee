//
//  RegisterViewController.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/15/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import SwiftValidator
import SwiftyUserDefaults
import PKHUD
import Intercom
import Firebase
import IQKeyboardManagerSwift



protocol RegistrationDelegate {
    func closeRegistrationView()
    func employerRegistered()
}
class RegisterViewController: UIViewController {

    @IBOutlet weak var passwordValidationErrorLabel: UILabel!
    @IBOutlet weak var numberValidationErrorLabel: UILabel!
    @IBOutlet weak var emailValidationErrorLabel: UILabel!
    @IBOutlet weak var nameValidationErrorLabel: UILabel!
    
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    
    var delegate : RegistrationDelegate?
    
    let validator = Validator()
    
    let dummyNumber = "MOBILE PHONE NUMBER"
    
    override func viewDidLoad() {
        super.viewDidLoad()

  //       Validation Rules are evaluated from left to right.
        
        validator.registerField(nameField, errorLabel: nameValidationErrorLabel , rules: [RequiredRule()])
        
        validator.registerField(emailField, errorLabel: emailValidationErrorLabel , rules: [RequiredRule(),EmailRule(message: "Invalid email")])
        
                // You can pass in error labels with your rules
                // You can pass in custom error messages to regex rules (such as ZipCodeRule and EmailRule)
                validator.registerField(passwordField , errorLabel:passwordValidationErrorLabel, rules: [RequiredRule()])
        
                 validator.registerField(numberField , errorLabel:numberValidationErrorLabel, rules: [RequiredRule(), PhoneNumberRule(country: "UK")])
        
        self.numberField.delegate = self
        self.numberField.text = dummyNumber
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    @IBAction func createAccountPressed(_ sender: Any) {
        validator.validate(self)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.clearAllFields()
        self.clearAllErrorLabel()
        delegate?.closeRegistrationView()
    }
    func moveToNextRegistrationStep(){
        
        
        delegate?.employerRegistered()
        
    }
    func clearAllFields(){
        
        self.nameField.text = ""
        self.emailField.text = ""
        self.passwordField.text = ""
        self.numberField.text = ""
    }
    
    func clearAllErrorLabel(){

        self.passwordValidationErrorLabel.text = ""
        self.numberValidationErrorLabel.text = ""
        self.emailValidationErrorLabel.text = ""
        self.nameValidationErrorLabel.text = ""
    }
}

extension RegisterViewController : UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == numberField{
          //  if textField.text == dummyNumber{
                textField.text = "+44"
          //  }
        }
       
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
        
        if textField == numberField{
            if textField.text?.length == 3 && string == ""{
                return false
            }
        }
        return true
    }
}
extension RegisterViewController : ValidationDelegate{
    
    func validationSuccessful() {
        
        let emp = EmployerDetails(name:(nameField.text) ?? ""  , email:emailField.text! , phoneNumber:numberField.text! , password:passwordField.text!)
        
        self.signup(withEmployer:emp , service: RegisterService())
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        
        // turn the fields to red
        for (_, error) in errors {
            /* if let field = field as? UITextField {
             field.layer.borderColor = UIColor.red.cgColor
             field.layer.borderWidth = 1.0
             }*/
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
            error.errorLabel?.textColor = UIColor.red
        }
        
    }
}

extension RegisterViewController{
    
    func signup(withEmployer epmloyerInfo: EmployerDetails, service : RegisterService)  {
        HUD.show(.progress)
        service.createEmployer(withInfo :epmloyerInfo  , completionHandler: {result in
            
            HUD.hide()
            switch result {
            case .Success(let user):
                
                //print("User access token = \(user.access_token?.characters.count)")
                
                
                if user.access_token != nil{
                   // HUD.flash(.success, delay: 0.0)
                    Defaults[.accessToken] = user.access_token
                    Defaults[.employerID] = user.employer_id as? Int
                    Defaults[.accessTokenExpiresIn] = user.expires_in!
                    Defaults[.hasUserRegistered] = true
                    Defaults[.email] = epmloyerInfo.email
                    Defaults[.password] = epmloyerInfo.password
                    Defaults[.refreshToken] = user.refresh_token
                    Defaults[.verificationCode] = user.verificationCode as! Int
                    Defaults[.name] = epmloyerInfo.name
                    DispatchQueue.main.async() {
                        self.moveToNextRegistrationStep()
                        Intercom.registerUser(withEmail: epmloyerInfo.email)
                    }
                   
                }else{
                   // HUD.flash(.error, delay: 1.0)
                    //self.errorAlert(description: user.message_detail!);
                }
                
            case .Failure(let error):
                print(error)
               // HUD.flash(.error, delay: 1.0)
                self.errorAlert(description: error.localizedDescription);
            }
            
        })
    }
    
}
