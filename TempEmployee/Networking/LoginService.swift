//
//  RegisterService.swift
//  Temp Provide
//
//  Created by kashif Saeed on 14/05/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation


// An 'URLRequestConvertible' object is created  through 'TemProvideRouter' class
// NetworkManager will send this request to server
// NetworkManager will send back 'JSON' object
// RegisterService will define success criteria for regsiter call

typealias JSONDict = [String:AnyObject]

struct Credential {
    var email: String!
    var password:String!
}
class Meta {
    
    var success : Bool
    var code : NSNumber
    var message : String
    var message_detail : String?
    
    
    init(jsonDict: JSONDict) {
        success = jsonDict["meta"]!["success"] as! Bool
        code = jsonDict["meta"]!["code"] as! NSNumber
        message = jsonDict["meta"]!["message"] as! String
        if let msg_detail = jsonDict["meta"]!["message_detail"] as? String{
            message_detail = msg_detail
        }
    }
    
}

class LoginData{
    
    var access_token : String?
    var token_type : String?
    var expires_in : Int?
    var refresh_token : String?            
    
    
    init(jsonDict: JSONDict) {
    
        access_token = jsonDict["access_token"] as? String
        token_type = jsonDict["token_type"] as? String
        expires_in = jsonDict["expires_in"] as? Int
        refresh_token = jsonDict["refresh_token"] as? String
    }
}

struct LoginService {

    enum RegisterResponse  {
        
        case emailExist
        case emailInvalid
       
        
        var localizedDescription: String {
            switch self {
            case .emailExist:
                return "The email has already been taken."
            case .emailInvalid:
                return "invalid email address"
            
            }
        }
    }
    
    
    
    func loginEmployerWith(credentials:Credential ,completionHandler: @escaping (Result<LoginData> ) -> Void) {
    
        NetworkManager.shared.callServer(with_request: TemProvideRouter.login(creds: credentials), completionHandler: {result in
        
            switch result {
                
            case .Success(let response):
                    print (response )
                    if (response["error"] as? String) != nil{
                        completionHandler(.Failure(NetworkError.tokenExpired))
                    }
                    let object = LoginData(jsonDict: response as JSONDict)
                    print("parsed data = ", object)
                completionHandler(.Success(object))
                    /*let success = response["meta"]!["success"] as? Bool
                    if success! {
                        
                        
                    }else{
                        
                }*/
                
            case .Failure(let error):
                    completionHandler(.Failure(error))
            }
            
        })
      
    }
    
    func refreshToken(completionHandler: @escaping (Result<LoginData> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.refreshToken(), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                
                let object = LoginData(jsonDict: response as JSONDict)
                completionHandler(.Success(object))
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }
}

