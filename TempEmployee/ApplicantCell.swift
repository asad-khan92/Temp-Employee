//
//  ApplicantCell.swift
//  TempEmployee
//
//  Created by Asad Khan on 12/12/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit

class ApplicantCell: UITableViewCell {

    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var hireButton: UIButton!
    @IBOutlet var rating: [UIButton]!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
