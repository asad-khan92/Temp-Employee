//
//  MainViewController.swift
//

import UIKit
import SwiftValidator
import SwiftyUserDefaults
import PKHUD
import Intercom
import Firebase
import IQKeyboardManagerSwift

class MainViewController: UIViewController {

    var needWalkthrough:Bool = true
    var walkthrough:BWWalkthroughViewController!
    
    let validator = Validator()
    
    var registerVC: RegisterViewController? {
        return self.walkthrough.childViewControllers.flatMap({ $0 as? RegisterViewController }).first
        // This works because `flatMap` removes nils
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentWalkthrough()
        
       let _ =  Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(changePage), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.registerVC?.delegate = self
    }

    @IBAction func presentWalkthrough(){
        
        let stb = UIStoryboard(name: "ShowCase", bundle: nil)
        walkthrough = stb.instantiateViewController(withIdentifier: "container") as! BWWalkthroughViewController
        let page_one = stb.instantiateViewController(withIdentifier: "page_1")
        let page_two = stb.instantiateViewController(withIdentifier: "page_2")
        let page_three = stb.instantiateViewController(withIdentifier: "page_3")
        
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.add(viewController: page_one)
        walkthrough.add(viewController: page_two)
        walkthrough.add(viewController: page_three)
        //walkthrough.add(viewController: page_four)
        
        self.present(walkthrough, animated: true) {
            ()->() in
            self.needWalkthrough = false
        }

    }
    
    func changePage(){
        
        if self.walkthrough.currentPage == 2{
            self.walkthrough.gotoPage(0)
        }else{
             self.walkthrough.gotoPage(self.walkthrough.currentPage + 1 )
            
        }
    }
}


extension MainViewController:BWWalkthroughViewControllerDelegate{
    
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
        if (self.walkthrough.numberOfPages - 1) == pageNumber{
            self.walkthrough.closeButton?.isHidden = false
        }else{
            self.walkthrough.closeButton?.isHidden = true
        }
    }
    
    func walkthroughRegisterButtonPressed(){
        
        self.walkthrough.registerContainerView.isHidden = false
        
        self.registerVC?.delegate = self
        
    }
    func walkthroughLoginButtonPressed(){
        
       self.walkthrough.loginView.isHidden = false
    }
    func walkthroughNextButtonPressed() {
        
    }
    
    func walkthroughForgotPasswordButtonPressed(){
        
        self.forgotPassword(userEmail:walkthrough.loginEmailField.text! , service: LoginService())
    }
    
    // Login method
    //
    func walkthroughGetWorkButtonPressed(){
        walkthroughGetBlowoutCoverButtonPressed()
    }
    func walkthroughGetBlowoutCoverButtonPressed(){
        
        
//        validator.unregisterField(walkthrough.registrationFormNameField)
//        validator.unregisterField(walkthrough.registrationFormEmailField)
//        validator.unregisterField(walkthrough.registrationFormNumberField)
//        validator.unregisterField(walkthrough.registrationFormPasswordField)
        
        
        // Validation Rules are evaluated from left to right.
        validator.registerField(walkthrough.loginEmailField , errorLabel: walkthrough.loginEmailErrorLabel , rules: [RequiredRule(),EmailRule(message: "Invalid email")])
        
        // You can pass in error labels with your rules
        // You can pass in custom error messages to regex rules (such as ZipCodeRule and EmailRule)
        validator.registerField(walkthrough.loginPasswordField , errorLabel:walkthrough.loginPasswordErrorLabel, rules: [RequiredRule()])
        
        validator.validate({errors in
            
            if errors.count > 0{
                
                for (_, error) in errors {
                    /* if let field = field as? UITextField {
                     field.layer.borderColor = UIColor.red.cgColor
                     field.layer.borderWidth = 1.0
                     }*/
                    error.errorLabel?.text = error.errorMessage // works if you added labels
                    error.errorLabel?.isHidden = false
                    error.errorLabel?.textColor = UIColor.red
                }
                
            }else{
                self.loginEmployer(fromService: LoginService(), withCreds:Credential(email:walkthrough.loginEmailField.text! , password: walkthrough.loginPasswordField.text!))
            }
    
        })
    }
    

    func validationSuccessful() {
        // after user have corrected all the fields remove the error labels text
       // removeErrorLabelText()
        
        
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
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
    
//    func removeErrorLabelText()  {
//        
//        for item in self.errorLabels {
//            item.text = ""
//        }
//    }
    
}

extension MainViewController: RegistrationDelegate{
    
    func closeRegistrationView() {
        self.walkthrough.registerContainerView.isHidden = true
    }
    
    func employerRegistered() {
        
        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        
        // instantiate your desired ViewController
        let controller : PhoneNumberVerificationController  = storyboard.instantiateViewController(withIdentifier: "PhoneNumberVerificationController") as! PhoneNumberVerificationController
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: true, completion: nil)
        
        appDelegate.navigationController?.pushViewController(controller, animated: true)
        
    }
}
//// MARK - Networking call
extension MainViewController{
    
    func forgotPassword(userEmail:String, service : LoginService){
        HUD.show(.progress, onView: walkthrough.view)
        service.forgotPassword(js_email: userEmail) { (result) in
            switch result{
                
            case .Success(let response):
                print(response)
                if response.success{
                    HUD.flash(.label("An email has been sent to your email address"), onView: self.walkthrough.view, delay: 4, completion: nil)
                }else{
                    HUD.flash(.label(response.message), onView: self.walkthrough.view, delay: 4, completion: nil)
                }
            case .Failure(let error):
                HUD.flash(.label(error.localizedDescription), onView: self.walkthrough.view, delay: 4, completion: nil)
                print(error)
            }
        }
    }
    
    func loginEmployer(fromService service: LoginService,  withCreds creds: Credential){
        
        HUD.show(.progress)
        service.loginEmployerWith(credentials:creds, completionHandler: {result in
            
            HUD.hide()
            switch result {
            case .Success(let user):
                
                //print("User access token = \(user.access_token?.characters.count)")
                
                
                if user.access_token != nil{
                    HUD.flash(.success, delay: 0.0)
                    Defaults[.accessToken] = user.access_token
                    Defaults[.accessTokenExpiresIn] = user.expires_in!
                    Defaults[.hasEmployerSignedIn] = true
                    Defaults[.email] = creds.email
                    Defaults[.password] = creds.password
                    Defaults[.refreshToken] = user.refresh_token
                    Intercom.registerUser(withEmail: creds.email)
                    self.moveToHomeScreen()
                }else{
                    HUD.flash(.error, delay: 1.0)
                    //self.errorAlert(description: user.message_detail!);
                }
                
            case .Failure(let error):
                print(error)
                HUD.flash(.error, delay: 1.0)
                self.errorAlert(description: error.localizedDescription);
            }
            
        })
    }
    
   
    func moveToHomeScreen()  {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // instantiate your desired ViewController
        let rootController : UITabBarController  = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: true, completion: nil)
        
        appDelegate.window?.rootViewController = rootController
        self.present(rootController, animated: false, completion: nil)
        
        
    }
   
}
