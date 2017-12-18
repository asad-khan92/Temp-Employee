//
//  UKPhoneNumberRule.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/15/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation
import SwiftValidator

/**
 `UKPhoneNumberRule` is a subclass of Rule that defines how a phone number is validated.
 */
extension PhoneNumberRule {
    //    let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
    
    /// Phone number regular express string to be used in validation.
    /// static let regex = "^\\d{10}$"
    static let ukPhoneNumberRegex = "^(?:(?:\\(?(?:0(?:0|11)\\)?[\\s-]?\\(?|\\+)44\\)?[\\s-]?(?:\\(?0\\)?[\\s-]?)?)|(?:\\(?0))(?:(?:\\d{5}\\)?[\\s-]?\\d{4,5})|(?:\\d{4}\\)?[\\s-]?(?:\\d{5}|\\d{3}[\\s-]?\\d{3}))|(?:\\d{3}\\)?[\\s-]?\\d{3}[\\s-]?\\d{3,4})|(?:\\d{2}\\)?[\\s-]?\\d{4}[\\s-]?\\d{4}))(?:[\\s-]?(?:x|ext\\.?|\\#)\\d{3,4})?$"
    
    static let pakPhoneNumberRegex = "^(?:(?:\\(?(?:0(?:0|11)\\)?[\\s-]?\\(?|\\+)92\\)?[\\s-]?(?:\\(?0\\)?[\\s-]?)?)|(?:\\(?0))(?:(?:\\d{5}\\)?[\\s-]?\\d{4,5})|(?:\\d{4}\\)?[\\s-]?(?:\\d{5}|\\d{3}[\\s-]?\\d{3}))|(?:\\d{3}\\)?[\\s-]?\\d{3}[\\s-]?\\d{3,4})|(?:\\d{2}\\)?[\\s-]?\\d{4}[\\s-]?\\d{4}))(?:[\\s-]?(?:x|ext\\.?|\\#)\\d{3,4})?$"
    
    /**
     Initializes a `PhoneNumberRule` object. Used to validate that a field has a valid phone number.
     
     - parameter message: Error message that is displayed if validation fails.
     - returns: An initialized `PasswordRule` object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public convenience init(country : String, message : String = "Enter a valid phone number") {
        if country == "Pakistan"{
            self.init(regex: PhoneNumberRule.pakPhoneNumberRegex, message : message)
        }else{
             self.init(regex: PhoneNumberRule.ukPhoneNumberRegex, message : message)
        }
    }
    
}

