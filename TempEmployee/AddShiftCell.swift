//
//  AddShiftCell.swift
//  TempEmployee
//
//  Created by kashif Saeed on 05/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit


class AddShiftCell: UITableViewCell {

    
    @IBOutlet weak var jobAddressField: AutoCompleteTextField!
    @IBOutlet weak var licenceView: UIView!
    
    @IBOutlet weak var jobRollField: UITextField!
    @IBOutlet weak var licenceRequiredField: UITextField!
    @IBOutlet weak var pricePerHourField: UnderLineTextField!
    @IBOutlet weak var hoursField: UnderLineTextField!
    @IBOutlet weak var startTimeField: UnderLineTextField!
    @IBOutlet weak var dateField: UnderLineTextField!
    
    @IBOutlet weak var pricePlusButton: UIButton!
    @IBOutlet weak var priceMinusButton: UIButton!
    @IBOutlet weak var hoursPlusButton: UIButton!
    @IBOutlet weak var hoursMinusButton: UIButton!
    @IBOutlet weak var dateDropDownButton: UIButton!
    @IBOutlet weak var startTimeDropDownButton: UIButton!
    //@IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var addLicenceButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var rollErrorLabel: UILabel!
    @IBOutlet weak var requiredLicenceErrorLabel: UILabel!
    @IBOutlet weak var priceErrorLabel: UILabel!
    @IBOutlet weak var dateErrorLabel: UILabel!
    @IBOutlet weak var hoursErrorLabel: UILabel!
    @IBOutlet weak var startTimeErrorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
