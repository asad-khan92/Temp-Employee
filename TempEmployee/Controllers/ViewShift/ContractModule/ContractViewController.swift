//
//  ContractViewController.swift
//  TempEmployee
//
//  Created by Asad Khan on 12/15/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyUserDefaults


protocol ContractSentDelegate {
    func contractSentTo(jobseeker:String)
}
class ContractViewController: UIViewController {
    

    @IBOutlet weak var contract: UITextView!
    var shiftID : Int!
    var jobseeker : JobSeeker!
    var delegate : ContractSentDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchContract(service: ContractService())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func sendContract(_ sender: Any) {
        
            self.sendHireContract(service: ContractService(),shiftID:shiftID)//, shiftID:"https://s3.eu-west-2.amazonaws.com/tempemployee/\(Defaults[.employerID]!)/Signature.png")
        
    }
    
    @IBAction func closeView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK : Networking calls

extension ContractViewController{
    
    func fetchContract (service : ContractService){
        
        HUD.show(.systemActivity)
        service.getJobContract(from:shiftID, completionHandler:{result in
            HUD.hide()
            switch result {
                
            case .Success(let data):
                
                if data.success{
                    self.contract.text = data.contractText
                }
                
            case .Failure(let error):
                print(error)
                
            }
        })
    }
    
    func uploadSignImage(img:UIImage){
        
        S3TransferManager.uploadImage(image:img , to: "Signature.png", jobSeekerId:Defaults[.employerID]!)
        {
            (result) in
            
            switch result {
                
            case .Success(let data):
                print(data)
            case .Failure(let error):
                print(error)
                
            }
        }
    }
    
    func sendHireContract(service:ContractService, shiftID:Int ){
        
        HUD.show(.progress, onView: self.view)
        
        service.sendJobContractTo(jobseekerID:Int(jobseeker.jobseeker_id!)! , of: shiftID,contract: self.contract.text) { (result) in
            HUD.hide()
            
            switch result {
                
            case .Success(let data):
                self.dismiss(animated: true, completion: nil)
                self.delegate?.contractSentTo(jobseeker: self.jobseeker.jobseeker_id)
                
                print(data)
                
            case .Failure(let error):
                print(error)
                
            }
            
        }
    }
}
