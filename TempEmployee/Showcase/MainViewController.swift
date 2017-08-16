//
//  MainViewController.swift
//  TB_Walkthrough
//
//  Created by Yari D'areglia on 12/03/16.
//  Copyright © 2016 Bitwaker. All rights reserved.
//

import UIKit
import BWWalkthrough
import SwiftValidator
import SwiftyUserDefaults
import PKHUD
import Intercom
import Firebase

class MainViewController: UIViewController, BWWalkthroughViewControllerDelegate {

    var needWalkthrough:Bool = true
    var walkthrough:BWWalkthroughViewController!
    
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentWalkthrough()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       /* if needWalkthrough {
            self.presentWalkthrough()
        }*/
    }

    @IBAction func presentWalkthrough(){
        
        let stb = UIStoryboard(name: "ShowCase", bundle: nil)
        walkthrough = stb.instantiateViewController(withIdentifier: "container") as! BWWalkthroughViewController
        let page_one = stb.instantiateViewController(withIdentifier: "page_1")
        let page_two = stb.instantiateViewController(withIdentifier: "page_2")
        let page_three = stb.instantiateViewController(withIdentifier: "page_3")
        //let page_four = stb.instantiateViewController(withIdentifier: "page_4")
        
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
        
        
        // Validation Rules are evaluated from left to right.
        validator.registerField(walkthrough.userNameField , errorLabel: walkthrough.userNameErrorField , rules: [RequiredRule(),EmailRule(message: "Invalid email")])
        
        // You can pass in error labels with your rules
        // You can pass in custom error messages to regex rules (such as ZipCodeRule and EmailRule)
        validator.registerField(walkthrough.passwordField , errorLabel:walkthrough.passwordErrorLabel, rules: [RequiredRule()])

    }
}


extension MainViewController:ValidationDelegate{
    
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
     
    }
    func walkthroughLoginButtonPressed(){
        
       self.walkthrough.loginView.isHidden = false
    }
    func walkthroughNextButtonPressed() {
        
    }
    func walkthroughGetBlowoutCoverButtonPressed(){
        
        
        validator.validate(self)
    }
    
    
    func validationSuccessful() {
        // after user have corrected all the fields remove the error labels text
       // removeErrorLabelText()
        
        self.loginEmployer(fromService: LoginService(), withEmail: walkthrough.userNameField.text!, password: walkthrough.passwordField.text!)
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
//// MARK - Networking call
extension MainViewController{
    
    
    
    
    func loginEmployer(fromService service: LoginService,  withEmail email: String, password:String){
        
        HUD.show(.progress)
        service.loginEmployerWith(email: email, password: password, completionHandler: {result in
            
            
            switch result {
            case .Success(let user):
                
                //print("User access token = \(user.access_token?.characters.count)")
                
                
                if user.access_token != nil{
                    HUD.flash(.success, delay: 0.0)
                    Defaults[.accessToken] = user.access_token
                    Defaults[.accessTokenExpiresIn] = user.expires_in!
                    Defaults[.hasUserRegistered] = true
                    Defaults[.email] = email
                    Defaults[.password] = password
                    Defaults[.refreshToken] = user.refresh_token
                     Intercom.registerUser(withEmail: email)
                    self.moveToNextRegistrationStep()
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
    
    
    func moveToNextRegistrationStep()  {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // instantiate your desired ViewController
        let rootController : UITabBarController  = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: true, completion: nil)
        
        appDelegate.window?.rootViewController = rootController
        self.present(rootController, animated: false, completion: nil)
        
        
    }
    
}
