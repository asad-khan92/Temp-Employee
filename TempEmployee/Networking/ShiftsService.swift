//
//  ShiftsService.swift
//  TempEmployee
//
//  Created by kashif Saeed on 01/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyUserDefaults

struct Licence{
    
     var id: NSNumber
     var license_name : String
    

}

class Shifts : Meta{
    
    var shifts = [Shift]()
     override init(jsonDict: JSONDict) {
        
        super.init(jsonDict: jsonDict)
        
        if self.success{
            let shiftsArray = jsonDict["data"] as? [[String:Any]]
            
            if ((shiftsArray?.count)! > 0) {
                
                for shift in  shiftsArray!{
                    
                    let requiredLicenceArray = shift["required_licenses"] as? [[String:Any]]
                    
                    var licenceArray = [Licence]()
                    if requiredLicenceArray != nil {
                   
                        for licence in requiredLicenceArray!{
                       
                            let licenceObject = Licence(id: licence["id"] as! NSNumber, license_name: licence["license_name"] as! String)
                        
                        licenceArray.append(licenceObject)
                   
                        }
                    }
                    
                    let status = ShiftStatus(rawValue: shift["assign_status"] as! Int)
                    
                    var ShiftObject = Shift(role: shift["role"] as? String, from_time: shift["from_time"] as? String, interview_time: shift["interview_time"] as? String, shift_hours: shift["shift_hours"] as? String, address: shift["address"] as? String, price_per_hour: shift["price_per_hour"] as? String, shift_date: shift["shift_date"] as? String, reporting_to: shift["reporting_to"] as? String, phone: shift["phone"] as? String, details: shift["details"] as? String, special_info: shift["special_info"] as? String, site_instructions: shift["site_instructions"] as? String, required_licenses:  licenceArray, id : shift["id"] as! Int,assigned_job_seeker_id: shift["assigned_job_seeker_id"] as? Int, lat: shift["lat"] as! Double, lng : shift["lng"] as! Double, assign_status:status ,created_at:shift["created_at"] as? String)
                    
                    
                    if shift["jobseeker_data"] != nil{
                    
                        let dict = shift["jobseeker_data"] as? [String:Any]
                        
                    ShiftObject.jobSeeker = JobSeeker(email:dict?["email"] as? String , username: dict?["username"] as? String, phone: dict?["phone"] as? String, city: dict?["city"] as? String, post_code: dict?["post_code"] as? String, address1: dict?["address1"] as? String, address2: dict?["address2"] as? String, dob: dict?["dob"] as? String, ni_no: dict?["ni_no"] as? String, image_path: dict?["image_path"] as? String, average_rating: dict?["average_rating"] as? Int)
                    }
                    shifts.append(ShiftObject)
                }
                
            }
        
    
        }
    }
}

struct ShiftsService {
    

    func fetchMyShifts(with completionHandler: @escaping (Result<Shifts> ) -> Void) {
        
        NetworkManager.callServer(with_request: TemProvideRouter.get, completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                let object = Shifts(jsonDict: response as JSONDict)
                print("parsed data = ", object)
                completionHandler(.Success(object))
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }
    func deleteShift(id:Int, completionHandler: @escaping (Result<Meta> ) -> Void) {
        
        NetworkManager.callServer(with_request: TemProvideRouter.deleteShift(id), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                let object = Meta(jsonDict: response as JSONDict)
                print("parsed data = ", object)
                completionHandler(.Success(object))
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }
    func repostShift(id:Int, completionHandler: @escaping (Result<Meta> ) -> Void) {
        
        NetworkManager.callServer(with_request: TemProvideRouter.repostShift(id), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                let object = Meta(jsonDict: response as JSONDict)
                print("parsed data = ", object)
                completionHandler(.Success(object))
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }
    
    
}
