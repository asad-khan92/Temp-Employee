//
//  ApplicantDetail.swift
//  TempEmployee
//
//  Created by Asad Khan on 12/12/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit

class ApplicantDetail: UIView {

    @IBOutlet weak var licenseStackView: UIStackView!
    @IBOutlet var applicantRating: [UIImageView]!
    @IBOutlet weak var applicantDistance: UILabel!
    @IBOutlet weak var applicantName: UILabel!
    @IBOutlet weak var applicantImageView: UIImageView!
    @IBOutlet weak var hireButton: UIButton!
    
    
    func set(rating:Int){
            
            
            for (index,imgView) in applicantRating.enumerated()
                
            {
                
                if index == rating{
                    
                    imgView.image = UIImage.init(named: "Unselected Star")
                    
                }else {
                
                    imgView.image = UIImage.init(named: "Selected Star")
                }
                
            }
            
            
        
    }
    
    func set(licenses:[Licence]){
        
        for license in licenses{
            
            let label = UILabel.init()
            label.text = license.license_name
            licenseStackView.addArrangedSubview(label)
        }
    }
}
