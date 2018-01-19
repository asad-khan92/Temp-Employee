//
//  JobSeekerStruct.swift
//  TempEmployee
//
//  Created by kashif Saeed on 10/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation


struct JobSeeker {
    let jobseeker_id :String!
    let email : String!
    let username : String!
    let phone : String?
    let city : String?
    let post_code : String?
    let address1 : String?
    //let address2 : String?
    let dob : String?
    let ni_no : String?
    let image_path : String?
    let average_rating : Int?
    let jobseeker_licenses : [Licence]
}
