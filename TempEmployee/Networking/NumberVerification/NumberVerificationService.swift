//
//  NumberVerificationService.swift
//  Temp Provide
//
//  Created by Asad Khan on 10/21/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit

class Code: Meta {
    
    var verificationCode : NSNumber?
    
    override init(jsonDict: JSONDict) {
        super.init(jsonDict: jsonDict)
        if self.success{
            let data = jsonDict["data"] as? [String:Any]
            verificationCode = data!["verification_code"] as! NSNumber
        }
    }
}
struct NumberVerificationService {
    
    func setUserNumberVerified( jobseekerID:Int ,completionHandler: @escaping (Result<Meta> ) -> Void) {
        
//        NetworkManager.shared.callServer(with_request: TemProvideRouter.phoneVerificationStatus(jobSeekerID:jobseekerID), completionHandler: {result in
//            
//            switch result {
//                
//            case .Success(let response):
//                print (response )
//                let object = Meta(jsonDict: response)
//                print("parsed data = ", object)
//                completionHandler(.Success(object))
//                
//            case .Failure(let error):
//                completionHandler(.Failure(error))
//            }
//            
//        })
        
    }
    
    func resendVerificationCode( jobseekerID:Int ,completionHandler: @escaping (Result<Code> ) -> Void) {
        
//        NetworkManager.shared.callServer(with_request: TemProvideRouter.resendPhoneVerificationCode(jobSeekerID:jobseekerID), completionHandler: {result in
//
//            switch result {
//
//            case .Success(let response):
//                print (response )
//                let object = Code(jsonDict: response)
//                print("parsed data = ", object)
//                completionHandler(.Success(object))
//
//            case .Failure(let error):
//                completionHandler(.Failure(error))
//            }
//
//        })
        
    }
}
