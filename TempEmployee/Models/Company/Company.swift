//
//  Company.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/16/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation

struct Company {
    let name : String
    let address: String
    let credit : CreditCard
    
    init(companyName : String, companyAddress: String, ccNumberStr : String, cvvNumberStr : String, expiry : String) {
        
        credit = CreditCard(number:ccNumberStr , cvv: cvvNumberStr, expiry: expiry)
        address = companyAddress
        name = companyName
    }
}

struct  CreditCard{
    
    let number : String
    let cvv : String
    let expiry : String
}
