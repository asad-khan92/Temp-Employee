//
//  ContractViewController.swift
//  TempEmployee
//
//  Created by Asad Khan on 12/15/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import EPSignature
import PKHUD
import SwiftyUserDefaults

class ContractViewController: UIViewController {
    
    @IBOutlet weak var signatureView: EPSignatureView!
    @IBOutlet weak var signHereImgView: UIImageView!
    @IBOutlet weak var contract: UITextView!
    var shiftID : Int!
    var jobseeker : JobSeeker!
     var signatureVC : EPSignatureViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchContract(service: ContractService())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signContractPressed(_ sender: Any) {
        
        signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: true)
        signatureVC?.signatureDelegate = self
        signatureVC?.showsSaveSignatureOption = false
        signatureVC?.subtitleText = "I agree to the terms and conditions"
        signatureVC?.title = jobseeker.username
        let nav = UINavigationController(rootViewController: signatureVC!)
        present(nav, animated: true, completion: nil)
        
    }
    
    @IBAction func sendContract(_ sender: Any) {
        
        if let image = signHereImgView.image{
            uploadSignImage(img: image)
            self.sendHireContract(service: ContractService(),shiftID:shiftID)//, shiftID:"https://s3.eu-west-2.amazonaws.com/tempemployee/\(Defaults[.employerID]!)/Signature.png")
            
        }else{
            HUD.flash(.label("Please sign the contract"), delay: 4.0)
        }
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

extension ContractViewController : EPSignatureDelegate{
    
    func epSignature(_: EPSignatureViewController, didCancel error : NSError) {
        print("User canceled")
    }
    
    func epSignature(_: EPSignatureViewController, didSign signatureImage : UIImage, boundingRect: CGRect) {
        print(signatureImage)
        signHereImgView.image = nil
        signHereImgView.image = signatureImage
        
    }
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
        
        service.sendJobContractTo(jobseekerID:Int(jobseeker.jobseeker_id!)! , of: shiftID) { (result) in
            
            switch result {
                
            case .Success(let data):
                let n: Int! = self.navigationController?.viewControllers.count
                
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//
//                //let pendingShiftViewController = appDelegate.navigationController?.viewControllers[n-2] as! PendingShiftViewController
//                let mainTabContrller : MainTabController? = appDelegate.navigationController?.viewControllers.filter{$0 is MainTabController}.first as? MainTabController
//                if let vc = mainTabContrller{
//                    self.navigationController?.popToViewController(vc, animated: true)
//                }
                print(data)
                
            case .Failure(let error):
                print(error)
                
            }
            
        }
    }
}
