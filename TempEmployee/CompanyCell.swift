//
//  CompanyCell.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/16/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import SwiftValidator

class CompanyCell: UITableViewCell {

    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var nameErrorLabel: UILabel!
    
    
    @IBOutlet weak var addressField: UnderLineTextField!
    @IBOutlet weak var nameField: UnderLineTextField!
    
    let validator = Validator()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 11.0, *) {
            addressField.underLineColor = UIColor(named:"Theme Blue Color")!
            nameField.underLineColor = UIColor(named:"Theme Blue Color")!
            
            
        } else {
            addressField.underLineColor = UIColor.init(hex:Constants.appBlueThemeColorHexString)
            nameField.underLineColor = UIColor.init(hex:Constants.appBlueThemeColorHexString)   
        }
        
        
        validator.registerField(addressField, errorLabel: addressErrorLabel, rules: [RequiredRule()])
        validator.registerField(nameField, errorLabel: nameErrorLabel, rules: [RequiredRule()])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension CompanyCell: ValidationDelegate{
    
    func validationSuccessful() {
        
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
