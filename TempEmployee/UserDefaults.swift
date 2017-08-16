//
//  UserDefaults.swift
//  Temp Provide
//
//  Created by kashif Saeed on 19/05/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation
import SwiftyUserDefaults


extension UserDefaults {
    subscript(key: DefaultsKey<[[String: String]]>) -> [[String: String]] {
        get { return unarchive(key) ?? [["":""]] }
        set { archive(key, newValue) }
    }
}

extension DefaultsKeys {
    // User Data fields to presist
    static let accessToken = DefaultsKey<String?>(Constants.Employer.accessToken)
    static let email = DefaultsKey<String?>(Constants.Employer.email)
    static let password = DefaultsKey<String?>(Constants.Employer.password)
    static let accessTokenExpiresIn = DefaultsKey<Int>(Constants.Employer.accessTokenExpireIn)
    // Setting App Root VC flags
    static let hasUserRegistered = DefaultsKey<Bool>(Constants.Employer.Registered)
    static let refreshToken = DefaultsKey<String?>(Constants.Employer.refreshToken)
    
    //static let hasUserSignedIn = DefaultsKey<Bool>(Constants.Employee.SignedIn)
}
