//
//  FCMTokenUpdateService.swift
//  Temp Provide
//
//  Created by kashif Saeed on 01/08/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit

struct FCMTokenUpdateService {

    
    func updateUserFCM( token:String ,completionHandler: @escaping (Result<[String:Any]> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.updateFCMToken(token: token), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                completionHandler(.Success(response))
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }
    
}
