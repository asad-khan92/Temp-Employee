//
//  Params.swift
//  Temp Provide
//
//  Created by kashif Saeed on 14/05/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class Params {
    
    public static func paramsForLogin(email : String = "admin@train4security.com" , password:String) -> [String:Any] {
        
        
        
        return [
            "username": email,
            "password": password,
            "client_id": "1",
            "client_secret": "test",
            "grant_type": "password"
            ]
    }
    
    public static func paramsForPostShift(data : Shift) -> [String:Any] {
        
        let licenceIDArray : [NSNumber] = data.required_licenses.flatMap{$0.id}
        let dic =  [
            "address":data.address!,
            "role":data.role!,
            "shift_date":data.shift_date!,
            "from_time":data.from_time!,
            "shift_hours":data.shift_hours!,
            "price_per_hour":data.price_per_hour!,
            "reporting_to":data.reporting_to!,
            "phone":data.phone!,
            "details":data.details!,
            "site_instructions":data.site_instructions!,
            "lat": data.lat!,
            "lng": data.lng!,
            "required_license":licenceIDArray,
        ] as [String : Any]
        return dic
    }
    
    public static func paramsForPostProfilePic(info : String) -> [String:Any] {
        
        
        return [
            "job_seeker_id":Defaults[.accessToken] ?? "",
            "image_string":info
        ]
    }
    public static func paramsForPostRating(jobseekerID : Int ,shiftID:Int,rating:Int,review:String) -> [String:Any] {
        
        
        return [
            "job_seeker_id":jobseekerID,
            "shift_id":shiftID,
            "rating":rating,
            "review":review
        ]
    }
    
    public static func paramsForSlotBooking(slotID : Int) -> [String:Any] {
        
        
        return [
            "job_seeker_id":Defaults[.accessToken] ?? "",
            "slot_id":slotID
        ]
    }
    
    public static func paramsForRefreshingToken()-> [String:Any]{
        
        return [
            "client_id": "1",
            "client_secret": "test",
            "grant_type": "refresh_token",
            "refresh_token": Defaults[.refreshToken] ?? ""
        ]
        
    }
}
