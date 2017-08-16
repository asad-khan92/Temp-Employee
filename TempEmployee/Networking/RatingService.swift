//
//  RatingService.swift
//  TempEmployee
//
//  Created by kashif Saeed on 11/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation

struct RateService{
    
    func post(shift:Shift , rating:Int, review:String ,completionHandler: @escaping (Result<Meta> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.postRating(shift.assigned_job_seeker_id!, shift.id,rating, review), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                let object = Meta(jsonDict: response as JSONDict)
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
}
