//
//  ShiftDetailController.swift
//  TempEmployee
//
//  Created by kashif Saeed on 07/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftValidator

class ShiftDetailController: UIViewController {

    @IBOutlet weak var siteInstructionErrorLabel: UILabel!
    @IBOutlet weak var specialInfoErrorLabel: UILabel!
    @IBOutlet weak var detailsErrorLabel: UILabel!
    @IBOutlet weak var contactNumberErrorField: UILabel!
    @IBOutlet weak var reportingErrorLabel: UILabel!
    
    
    @IBOutlet weak var siteInstructionField: SkyFloatingLabelTextField!
   // @IBOutlet weak var specialInfoField: SkyFloatingLabelTextField!
    @IBOutlet weak var detailsField: SkyFloatingLabelTextField!
    @IBOutlet weak var contactNumberField: SkyFloatingLabelTextField!
    @IBOutlet weak var reportingField: SkyFloatingLabelTextField!
    
    var shift : Shift?
    var isEditingShift:  Bool?
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        validator.registerField(reportingField , errorLabel:reportingErrorLabel, rules: [RequiredRule()])
        validator.registerField(contactNumberField , errorLabel:contactNumberErrorField, rules: [RequiredRule(),MaxLengthRule(length: 11),MinLengthRule(length: 7)])
       validator.registerField(detailsField , errorLabel:detailsErrorLabel, rules: [RequiredRule()])
        
    }

    func filledTextFieldWithShiftData()  {
        
        self.siteInstructionField.text = self.shift?.site_instructions
        //self.specialInfoField.text  = self.shift?.special_info
        self.detailsField.text = self.shift?.details
        self.contactNumberField.text = self.shift?.phone
        self.reportingField.text = self.shift?.reporting_to
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        validator.validate(self)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
       let _ = self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.siteInstructionField.placeholderFont = UIFont.init(name: "HalisR-Regular", size: 12)!
        //self.specialInfoField.placeholderFont = UIFont.init(name: "Lato-Light", size: 12)!
        self.detailsField.placeholderFont = UIFont.init(name: "HalisR-Regular", size: 12)!
        self.contactNumberField.placeholderFont = UIFont.init(name: "HalisR-Regular", size: 12)!
        self.reportingField.placeholderFont = UIFont.init(name: "HalisR-Regular", size: 12)!
        
        if self.isEditingShift!{
            
            self.filledTextFieldWithShiftData()
        }
        
    }
}
extension ShiftDetailController:ValidationDelegate{
    
    func validationSuccessful() {
        // after user have corrected all the fields remove the error labels text
        // removeErrorLabelText()
       
        
            self.shift?.reporting_to = self.reportingField.text
        
            self.shift?.details = self.detailsField.text
        
             //self.shift?.special_info = self.specialInfoField.text
        
            self.shift?.site_instructions = self.siteInstructionField.text
        
            self.shift?.phone = self.contactNumberField.text
        
        self.moveToNextStep()
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
    
    func moveToNextStep(){
        
        let storyboard = UIStoryboard.init(name: "AddShift", bundle: nil)
        
        let billVC : BillViewController = storyboard.instantiateViewController()
        
        billVC.shift = self.shift!
        billVC.isEditingShift = self.isEditingShift
        
        self.navigationController?.pushViewController(billVC, animated: true)
    }
}
