//
//  CompanyAccountCell.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/16/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import SwiftValidator
import PKHUD
import AFDateHelper


protocol  CompanyAccountCellDelegate{
    
    func validationSuccessfull()
    func expiryFieldsDidBeginEditing(field:UnderLineTextField)
}
class CompanyAccountCell: UITableViewCell {

    @IBOutlet weak var cvvErrorLabel: UILabel!
    @IBOutlet weak var expiryDateErrorLabel: UILabel!
    @IBOutlet weak var numberErrorLabel: UILabel!
    
    
    @IBOutlet var cvvFields: [UnderLineTextField]!
    @IBOutlet weak var expiryYearField: UnderLineTextField!
    @IBOutlet weak var expiryMonthField: UnderLineTextField!
    @IBOutlet weak var numberField: UnderLineTextField!
    
    var delegate : CompanyAccountCellDelegate?
    var validator = Validator()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        if #available(iOS 11.0, *) {
             expiryYearField.underLineColor = UIColor(named:"Theme Blue Color")!
             expiryMonthField.underLineColor = UIColor(named:"Theme Blue Color")!
             numberField.underLineColor = UIColor(named:"Theme Blue Color")!
             let _ = cvvFields.map({$0.underLineColor = UIColor(named:"Theme Blue Color")!})
            
        } else {
            expiryYearField.underLineColor = UIColor.init(hex:Constants.appBlueThemeColorHexString)
            expiryMonthField.underLineColor = UIColor.init(hex:Constants.appBlueThemeColorHexString)
            numberField.underLineColor = UIColor.init(hex:Constants.appBlueThemeColorHexString)
            let _ = cvvFields.map({$0.underLineColor =  UIColor.init(hex:Constants.appBlueThemeColorHexString)})
            
        }
        
        _ = cvvFields.map{$0.delegate = self}
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object:cvvFields[0])
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object:cvvFields[1])
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object:cvvFields[2])
        
        expiryYearField.delegate = self
        expiryMonthField.delegate = self
        
        validator.registerField(expiryYearField, errorLabel:expiryDateErrorLabel ,rules:[RequiredRule()] )
        validator.registerField(expiryMonthField, errorLabel:expiryDateErrorLabel ,rules:[RequiredRule()] )
        
        validator.registerField(numberField, errorLabel:numberErrorLabel ,rules:[RequiredRule(),MaxLengthRule(length: 19)] )
        
        validator.registerField(cvvFields.first!, errorLabel:cvvErrorLabel ,rules:[RequiredRule(),MaxLengthRule(length: 1)] )
        validator.registerField(cvvFields[1], errorLabel:numberErrorLabel ,rules:[RequiredRule(),MaxLengthRule(length: 19)] )
        validator.registerField(cvvFields.last!, errorLabel:numberErrorLabel ,rules:[RequiredRule(),MaxLengthRule(length: 19)] )
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
}
extension CompanyAccountCell : ValidationDelegate{
    func validationSuccessful() {
        delegate?.validationSuccessfull()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        
        // turn the fields to red
        for (_, error) in errors {
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
            error.errorLabel?.textColor = UIColor.red
        }
        
    }
    
}
extension CompanyAccountCell:UITextFieldDelegate{
    
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField == expiryYearField || textField == expiryMonthField) {
            
            delegate?.expiryFieldsDidBeginEditing(field: textField as! UnderLineTextField)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    
    
    
    func donePressed(_ sender: UIBarButtonItem) {
        
        if expiryMonthField.text == ""{
            HUD.flash(.labeledError(title: "Oops!", subtitle: "No expiry date selected"), delay: 3)
            return
        }
        expiryMonthField.resignFirstResponder()
        expiryYearField.resignFirstResponder()
        
    }
    
    func textFieldTextDidChange(_ notification: Notification){
        
        let textField = notification.object as! UnderLineTextField
        let nextFieldIndex = cvvFields.index(of: textField)! + 1
        if nextFieldIndex < cvvFields.count && textField.text!.length > 0 {
            textField.resignFirstResponder()
            cvvFields[nextFieldIndex].becomeFirstResponder()
        }else if nextFieldIndex == cvvFields.count{
            
            textField.resignFirstResponder()
        }
        
    }
}
