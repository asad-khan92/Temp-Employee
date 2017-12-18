//
//  CompanyInfoController.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/16/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import SwiftValidator
import PKHUD
import DropDown
import SwiftyUserDefaults


class CompanyInfoController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var picker : DatePickerView = DatePickerView.init(frame: CGRect.zero)
    fileprivate var companyCell : CompanyCell!
    fileprivate var accountInfoCell : CompanyAccountCell!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishPressed(_ sender: Any) {
        self.companyCell.validator.validate({(errors) in
            
            if errors.count == 0{
                
                self.accountInfoCell.validator.validate({(errors) in
                    
                    if errors.count == 0{
                        let expiryDate = ("01 " + accountInfoCell.expiryMonthField.text! + " " + accountInfoCell.expiryYearField.text!)
                        
                        let company = Company(companyName: companyCell.nameField.text!, companyAddress:companyCell.addressField.text! , ccNumberStr: accountInfoCell.numberField.text!, cvvNumberStr: accountInfoCell.cvvFields.flatMap{$0.text!}.reduce("",+), expiry:expiryDate )
                        
                        self.postCompanyDetail(service: CompanyServices(), param: company)
                    }else{
                        self.showErrorFields(errors: errors)
                    }
                })
                
            }else{
                
                self.showErrorFields(errors: errors)
            }
        })
       
    }
    
    func showErrorFields(errors:[(Validatable, ValidationError)]){
        
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
    func moveToNextController(){
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//        // instantiate your desired ViewController
//        let rootController : UITabBarController  = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
//
//
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        //self.dismiss(animated: true, completion: nil)
//
//        appDelegate.window?.rootViewController = rootController
//       appDelegate.navigationController?.setViewControllers([
//        rootController], animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // instantiate your desired ViewController
        let rootController : UITabBarController  = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
        appDelegate.setRootController(root: rootController)
        /*let rootController : ThankViewController  = storyboard.instantiateViewController(withIdentifier: "ThankViewController") as! ThankViewController*/
        
        //self.window?.rootViewController = rootController
        DropDown.startListeningToKeyboard()
        
        
    }
}

extension CompanyInfoController : UITableViewDataSource, UITableViewDelegate{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            self.tableView.register(UINib.init(nibName:"CompanyCell" , bundle:Bundle.main), forCellReuseIdentifier: "CompanyCell")

            let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyCell", for: indexPath) as! CompanyCell
            companyCell = cell
            return cell
        }else{
            self.tableView.register(UINib.init(nibName:"CompanyAccountCell" , bundle:Bundle.main), forCellReuseIdentifier: "CompanyAccountCell")

            let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyAccountCell", for: indexPath) as! CompanyAccountCell
            accountInfoCell = cell
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel.init()
        label.frame = CGRect.init(origin: CGPoint.init(x: 0.0, y: 0.0), size: CGSize.init(width:tableView.frame.width, height: 50))
        label.font = UIFont.init(name: "HalisR-Bold", size: 20)
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        if #available(iOS 11.0, *) {
            label.textColor = UIColor(named: "Theme Blue Color")
        } else {
            // Fallback on earlier versions
            label.textColor = UIColor.init(hex:"#6398FB")
        }
        label.text = "PAYMENT INFORMATION"
        if section == 0{
           label.text = "COMPANY INFORMATION"
        }
        
        return label 
    }
  
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{

            return 158
        }else{

            return 230
        }
    }
}

extension CompanyInfoController: CompanyAccountCellDelegate{
    
    func validationSuccessfull() {
        
    }
    
    func expiryFieldsDidBeginEditing(field: UnderLineTextField) {
        
        let formatter = DateFormatter.init()
        formatter.locale = Locale.init(identifier: "en_US")
        formatter.dateFormat = "yyyy"
        let minYear = Date.init()
        let maxYear = formatter.string(from: minYear.adjust(.year, offset: 30))
        
        // not converting minYear as it is already in yy format
        picker.minYear = Int(formatter.string(from:Date.init()))!
        picker.maxYear = Int(maxYear)!
        picker.rowHeight = 60
        
        picker.selectToday()
        picker.selectRow(50, inComponent: 1, animated: false)
        picker.selectRow(500, inComponent: 0, animated: false)
        
        var frame = picker.bounds
        frame.origin.y = picker.frame.size.height
        picker.frame = frame
        
        //self.view.addSubview(picker)
        picker.selectToday()
        picker.dpDelegate = self
        field.inputView = picker
    }
}

extension CompanyInfoController:DatePickerDelegate{
    
    func pickerView(didSelectYear year: String) {
        accountInfoCell.expiryYearField.text = year
    }
    
    func pickerView(didSelectMonth month: String) {
       accountInfoCell.expiryMonthField.text = month
    }
}

extension CompanyInfoController{
    
    func postCompanyDetail(service: CompanyServices, param: Company){
        
        HUD.show(.progress)
        service.postCompany(Info: param) { (result) in
        
            HUD.hide()
            
            switch result{
                
            case .Success( _):
                Defaults[.hasEmployerSignedIn] = true
                self.moveToNextController()
            case .Failure(let error):
                print(error)
            }
        }
    }
}
