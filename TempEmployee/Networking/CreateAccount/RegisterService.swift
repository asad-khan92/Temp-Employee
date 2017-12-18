//
//  Register.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/13/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation

struct EmployerDetails{
    
    var name : String!
    var email: String!
    var phoneNumber : String!
    var password : String!
}

class RegisterResponse:Meta{
    
    var employer_id : NSNumber?
    var verificationCode : NSNumber?
    var access_token : String?
    var token_type : String?
    var expires_in : Int?
    var refresh_token : String?
    
    override init(jsonDict: JSONDict) {
        
        employer_id = jsonDict["data"]!["employer_id"] as? NSNumber
        verificationCode = jsonDict["data"]!["verification_code"] as? NSNumber
        access_token = jsonDict["data"]!["access_token"] as? String
        token_type = jsonDict["data"]!["token_type"] as? String
        expires_in = jsonDict["data"]!["expires_in"] as? NSNumber as! Int
        refresh_token = jsonDict["data"]!["refresh_token"] as? String
        
        super.init(jsonDict: jsonDict)
    }
}

struct RegisterService{
    
    func createEmployer(withInfo details: EmployerDetails, completionHandler:@escaping(Result<RegisterResponse>)->Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.registerEmployer(info: details), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                let object = RegisterResponse(jsonDict: response as JSONDict)
                print("parsed data = ", object)
                completionHandler(.Success(object))
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
    }
}
