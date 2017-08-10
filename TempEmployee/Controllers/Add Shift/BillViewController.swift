//
//  BillViewController.swift
//  TempEmployee
//
//  Created by kashif Saeed on 08/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import PKHUD

class BillViewController: UIViewController {

    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var totalCharges: UILabel!
    @IBOutlet weak var vatCharges: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var cardCharges: UILabel!
    @IBOutlet weak var tempProvideFee: UILabel!
    @IBOutlet weak var perHourCharges: UILabel!
    
    var shift : Shift!
    var isEditingShift:  Bool?
    var charges: Charges?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getShiftCharges(service: CreateShift())
    }

   
    override func viewWillAppear(_ animated: Bool){
    
    
        super.viewWillAppear(animated)
        
        self.firstView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        self.secondView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        self.thirdView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateKeyframes(withDuration: 0.9, delay: 0.0, options: .calculationModeLinear, animations: {
            // each keyframe needs to be added here
            // within each keyframe the relativeStartTime and relativeDuration need to be values between 0.0 and 1.0
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                
                self.firstView.alpha = 1
                self.firstView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3, animations: {
                
                self.secondView.alpha = 1
                self.secondView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.3, animations: {
                
                self.thirdView.alpha = 1
                self.thirdView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
            })
            
            
        }, completion: {finished in
            // any code entered here will be applied
            // once the animation has completed
            
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addCharges(){
        
        self.perHourCharges.text = "£\(self.shift.getTotalPPH())"
        self.tempProvideFee.text =  "£\(self.charges?.tempProvideFee ?? 25)"
        self.cardCharges.text =  "£\(self.charges?.cardCharges ?? 3)"
        self.vatCharges.text =  "\(self.charges?.valueAddedTax ?? 20)%"
        
        let cCharges = self.removeCurrencySignAndConvertToDouble(str: self.cardCharges.text!)
        let fee      = self.removeCurrencySignAndConvertToDouble(str: self.tempProvideFee.text!)
       // let vCharges = self.removeCurrencySignAndConvertToDouble(str: self.vatCharges.text!)
        
        
        self.subTotal.text =  "£\(self.shift.getSubtotal(cardCharges: cCharges, tempProvide:fee))"
        
        if let sT = self.subTotal.text{
            let sTotal = self.removeCurrencySignAndConvertToDouble(str: sT)
            self.totalCharges.text =  "\(self.shift.getTotalIncludig(vat:(self.charges?.valueAddedTax)! , subTotal: sTotal))"
        }
    }
    @IBAction func getCoveredPressed(_ sender: Any) {
        
        if (self.isEditingShift)!{
            self.updateShift(service: CreateShift())
        }else{
        
            self.postShift(service: CreateShift())
        }
    }
    @IBAction func cancelPressed(_ sender: Any) {
        
        self.popToRoot()
    }
    func removeCurrencySignAndConvertToDouble(str : String) -> Double {
       return Double(str.replacingOccurrences(of: "£", with: ""))!
    }
    
    func popToRoot() {
        let _ = self.navigationController?.popToRootViewController(animated: false)
        self.tabBarController?.selectedIndex = 0
    }
}


extension BillViewController{
    
    
    func getShiftCharges(service:CreateShift)  {
        
        HUD.show(.progress,onView: self.view)
        service.getCharges(completionHandler:{result in
            
            switch result {
                
            case .Success(let response):
                if response.success{
                    HUD.flash(.success, delay: 0.0)
                    self.charges = response
                    self.addCharges()
                }else{
                    HUD.flash(.error, delay: 0.0)
                    self.errorAlert(description: response.message)
                }
            case .Failure(let error):
                HUD.flash(.error, delay: 0.0)
                self.errorAlert(description: error.localizedDescription)
            }
        })
    }
    
    func postShift(service:CreateShift)  {
        
        HUD.show(.progress,onView: self.view)
        service.createShift(shift: self.shift!, completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                    if response.success{
                        HUD.flash(.success, delay: 0.0)
                        NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constants.Notifications.shiftPosted) , object: nil)
                        self.popToRoot()
                    }else{
                        HUD.flash(.error, delay: 0.0)
                        self.errorAlert(description: response.message)
                }
            case .Failure(let error):
                HUD.flash(.error, delay: 0.0)
                self.errorAlert(description: error.localizedDescription)
            }
        })
    }
    
    func updateShift(service:CreateShift)  {
        
        HUD.show(.progress,onView: self.view)
        service.updateShift(shift: self.shift!, completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                if response.success{
                    HUD.flash(.success, delay: 0.0)
                    self.popToRoot()
                }else{
                    HUD.flash(.error, delay: 0.0)
                    self.errorAlert(description: response.message)
                }
            case .Failure(let error):
                HUD.flash(.error, delay: 0.0)
                self.errorAlert(description: error.localizedDescription)
            }
        })
    }
    
    
    func repostShift(service:ShiftsService ,shiftID : Int, showIndicator:Bool)  {
        
        if showIndicator {
            HUD.show(.progress,onView: self.view)
        }
        
        service.repostShift(id: shiftID, completionHandler:   {result in
            
            switch result{
                
            case .Success(let response):
                print(response)
                HUD.hide()
                if response.success{
                    NotificationCenter.default.post(name:NSNotification.Name(rawValue: Constants.Notifications.shiftPosted) , object: nil)
                    self.popToRoot()
                }else{
                    HUD.hide()
                    
                    self.errorAlert(description: response.message)
                }
            case .Failure(let error):
                
                HUD.hide()
                self.errorAlert(description: error.localizedDescription)
                print(error)
            }
        })
    }
}
