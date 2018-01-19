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
                    
                    let requiredLicenceArray = shift["licenses"] as? [[String:Any]]
                    
                    var licenceArray = [Licence]()
                    if requiredLicenceArray != nil {
                   
                        for licence in requiredLicenceArray!{
                       
                            let licenceObject = Licence(id: licence["id"] as! NSNumber, license_name: licence["license_name"] as! String)
                        
                        licenceArray.append(licenceObject)
                   
                        }
                    }
                    
//                    let status = AssignStatus(rawValue: shift["assign_status"] as! Int)
                   var shiftStatus =  ShiftStatus(rawValue: 0)
                    
                    if let value =  shift["shift_status"] as? Int{
                         shiftStatus = ShiftStatus(rawValue: value)
                    }
                    
                    var ShiftObject = Shift(role: shift["role"] as? String, from_time: shift["from_time"] as? String, shift_hours: shift["shift_hours"] as? String, address: shift["address"] as? String, price_per_hour: shift["price_per_hour"] as? Float, shift_date: shift["shift_date"] as? String, reporting_to: shift["reporting_to"] as? String, phone: shift["phone"] as? String, details: shift["details"] as? String, special_info: shift["special_info"] as? String ?? "", site_instructions: shift["site_instructions"] as? String, required_licenses:  licenceArray, id : shift["id"] as! Int,assigned_job_seeker_id: shift["assigned_job_seeker_id"] as? Int, lat: shift["lat"] as! Double, lng : shift["lng"] as! Double ,created_at:shift["created_at"] as? String,totalCost:shift["total_cost"] as? Float,shift_status:shiftStatus)
                    
                    
                    if shift["jobseekers"] != nil{
                    
                        let jobseekerRawArray = shift["jobseekers"] as? [[String:Any]]
                        
                        var jobseekerArray = [JobSeeker]()
                        for jobseeker in jobseekerRawArray!{
                            
                            var licenseArray = [Licence]()
                            
                            if let licenseInfoArray = jobseeker["jobseeker_licenses"] as? [[String:Any]]{
                                
                                for license in licenseInfoArray{
                                    licenseArray.append(Licence(id: NSNumber.init(value:license["id"] as! Int), license_name: license["license_name"] as! String))
                                }
                            }
                            let js = JobSeeker(jobseeker_id: "\(jobseeker["jobseeker_id"]!)", email: jobseeker["email"] as! String, username: jobseeker["username"] as! String, phone: jobseeker["phone"] as! String, city: jobseeker["city"] as! String, post_code: jobseeker["post_code"] as! String, address1: jobseeker["address1"] as! String, dob: jobseeker["dob"] as? String ?? "", ni_no: jobseeker["ni_no"] as? String ?? "", image_path: jobseeker["image_path"] as! String, average_rating: jobseeker["average_rating"] as? Int ?? 0, jobseeker_licenses: licenseArray)
                           
                            jobseekerArray.append(js)
                        }
                    ShiftObject.jobSeekers = jobseekerArray
                    }
                    shifts.append(ShiftObject)
                }
                
            }
        
    
        }
    }
}

struct ShiftsService {
    

    func fetchMyShifts(with completionHandler: @escaping (Result<Shifts> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.get, completionHandler: {result in
            
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
    
    func fetchPosted(with completionHandler: @escaping (Result<Shifts> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.getPostedShift, completionHandler: {result in
            
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
    
    func fetchCovered(with completionHandler: @escaping (Result<Shifts> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.getCoveredShift, completionHandler: {result in
            
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
    
    func fetchCompleted(with completionHandler: @escaping (Result<Shifts> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.getCompletedShift, completionHandler: {result in
            
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
    
    func fetchExpired(with completionHandler : @escaping (Result<Shifts>)-> Void)  {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.getExpiredShift, completionHandler: {result in
            
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
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.deleteShift(id), completionHandler: {result in
            
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
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.repostShift(id), completionHandler: {result in
            
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
