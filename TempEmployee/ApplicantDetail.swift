//
//  ApplicantDetail.swift
//  TempEmployee
//
//  Created by Asad Khan on 12/12/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit

protocol  ApplicantDetailDelegate{
    func hire(jobseeker:JobSeeker)
}
class ApplicantDetail: UIView {

    @IBOutlet weak var licenseStackView: UIStackView!
    @IBOutlet var applicantRating: [UIImageView]!
    @IBOutlet weak var applicantDistance: UILabel!
    @IBOutlet weak var applicantName: UILabel!
    @IBOutlet weak var applicantImageView: UIImageView!
    @IBOutlet weak var hireButton: UIButton!
    @IBOutlet weak var hireApplicantName: UILabel!
    @IBOutlet weak var hireView: UIView!
    
    @IBOutlet weak var contactView: UIStackView!
    var applicant : JobSeeker!
    var delegate : ApplicantDetailDelegate!
    var jobSeekerAlreadyHired : Bool!
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.applicantName.text = applicant.username
        self.applicantName.text = applicant.username
        self.hireApplicantName.text = applicant.username
        self.applicantImageView.sd_setImage(with:URL.init(string:applicant.image_path!))
        self.set(rating:applicant.average_rating!)
        self.set(licenses: applicant.jobseeker_licenses)
        
        if jobSeekerAlreadyHired{
            self.hireView.isHidden = true
            self.contactView.isHidden = false
        }
    }
    func set(rating:Int){
            
            
            for (index,imgView) in applicantRating.enumerated()
                
            {
                
                if index == rating{
                    
                    imgView.image = UIImage.init(named: "Unselected Star")
                        break
                }else {
                
                    imgView.image = UIImage.init(named: "Selected Star")
                }
                
            }
        
            
        
    }
    
    func set(licenses:[Licence]){
        
        var count = 0;
        for license in licenses{
            
            let label = UILabel.init()
            label.font = UIFont.HalisRRegular(size: 15)
            label.numberOfLines = 0
            label.sizeToFit()
            label.text = license.license_name
            licenseStackView.alignment = .fill
            licenseStackView.spacing = 10
            licenseStackView.addArrangedSubview(label)
           // licenseStackView.insertArrangedSubview(label, at: count)
            count = count + 1
        }
    }
    @IBAction func whatsAppPressed(_ sender: Any) {
        
        
       // if self.applicant.phone == nil{
            
            let alert = UIAlertController(title: "Alert",message:" \(self.applicant.username!) have not provided his contact number",
                preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",style:UIAlertActionStyle.default,handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            
            return
     //   }
        if let contactNumber = self.applicant?.phone{
            
            var stringURL : String
            if contactNumber.hasPrefix("+") ||  contactNumber.hasPrefix("+44"){
                
                let number = contactNumber.replacingOccurrences(of: "+", with: "")
                stringURL = "https://api.whatsapp.com/send?phone=\(number)&text=hello"
            }else{
                stringURL = "https://api.whatsapp.com/send?phone=44\(contactNumber)&text=hello"
            }
            
            self.openSharedURl(str:stringURL , type: .whatsApp)
            
            
            
        }
        
    }
    @IBAction func callPressed(_ sender: Any) {
        
        if self.applicant.phone == nil{
            
            let alert = UIAlertController(title: "Alert",message:" \(self.applicant.username!) have not provided his contact number",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK",style:UIAlertActionStyle.default,handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
           
            return
        }
        if let contactNumber = self.applicant.phone{
            
            let str = "tel:\(contactNumber)"
            self.openSharedURl(str:str , type: .call)
            
            
        }
        
    }
    
    func openSharedURl(str:String , type:ContactType) {
        
        let urlString = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlString!)
        if url == nil{
            
            return
        }
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: { reult in
                
                print("\(url) \(reult)")
            })
            
        }
        
    }
    
    @IBAction func hire(_ sender: Any) {
        delegate?.hire(jobseeker: applicant)
    }
}
