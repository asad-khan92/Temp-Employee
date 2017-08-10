//
//  ShiftStruct.swift
//  TempEmployee
//
//  Created by kashif Saeed on 09/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation
import AFDateHelper


public enum ShiftMode :Int{
    case posting = 0
    case editing = 1
    case reposting = 2
    
}


public enum AssignStatus :Int{
    case pending = 0
    case covered = 1
    //case completed = 2

}

public enum ShiftStatus :Int{
    
    case SHIFT_TO_BE_COVERED = 0
    case SHIFT_FULLY_COVERED = 1
    case SHIFT_PARTIALLY_COVERED = 2
    case SHIFT_UNCOVERED_OR_EXPIRED = 3
    
}

struct Shift  {
    
    var id: Int!
    var assigned_job_seeker_id: Int?
    var role: String?
    var from_time: String?
    var interview_time: String?
    var shift_hours: String?
    var address: String?
    var price_per_hour: Float!
    var shift_date: String?
    var lat: Double?
    var lng: Double?
    
    var reporting_to: String?
    var phone: String?
    var details: String?
    var special_info: String?
    var site_instructions: String?
    var required_licenses: [Licence]
    var jobSeeker: JobSeeker?
    var assign_status : AssignStatus!
    var created_at : String!
    var shift_status : ShiftStatus!
    var shift_mode : ShiftMode! =  ShiftMode(rawValue: 0)
    
    init(role:String?,from_time: String?, interview_time: String?,shift_hours: String?,address: String?,price_per_hour: Float!,shift_date: String?,reporting_to: String?,phone: String?,details: String?,special_info: String?,site_instructions: String?,required_licenses: [Licence],id:Int,assigned_job_seeker_id:Int?, lat: Double, lng:Double,assign_status:AssignStatus!, created_at:String?,shift_status:ShiftStatus) {
        
        self.id = id
        self.assigned_job_seeker_id = assigned_job_seeker_id
        self.role = role
        self.from_time = from_time
        self.interview_time = interview_time
        self.shift_hours = shift_hours
        self.shift_date = shift_date
        self.address = address
        self.price_per_hour = price_per_hour
        self.lat = lat
        self.lng = lng
        self.reporting_to = reporting_to
        self.phone = phone
        self.details = details
        self.special_info = special_info
        self.site_instructions = site_instructions
        self.required_licenses = required_licenses
        self.assign_status = assign_status
        self.created_at = created_at
        self.shift_status = shift_status
        
        
    }
    
    init(role:String?,from_time: String?,shift_hours: String?,address: String?,price_per_hour: Float!,shift_date: String?,required_licenses: [Licence] , latitude:Double, longitude:Double) {
        
        self.role = role
        self.from_time = from_time
        self.shift_hours = shift_hours
        self.shift_date = shift_date
        self.address = address
        self.price_per_hour = price_per_hour
        self.required_licenses = required_licenses
        self.lat = latitude
        self.lng = longitude
    }
    
    func getTotalPPH() -> Double {
        let pph = Double(self.price_per_hour!)
        let hours = Double(self.shift_hours!)
        return (pph * hours!)
    }
    func getSubtotal(cardCharges:Double,tempProvide fee:Double) -> Double {
      
        
        return (self.getTotalPPH() + cardCharges + fee)
        
    }
    func getTotalIncludig(vat:Double , subTotal : Double) -> Double {
        
        return (subTotal + (subTotal * vat)/100)
    }
    
    func isPostedWithinAnHour() -> DateComponents? {
       
        
       let shiftCreatedAt =  Date.init(fromString: self.created_at, format: .custom("yyyy-MM-dd HH:mm:ss"), timeZone: TimeZoneType.utc, locale: Locale.init(identifier: "en_GB"))
        
        let currentDate = Date.init()
        
        return  Calendar.current.dateComponents([.hour,.minute], from: shiftCreatedAt!, to: currentDate)
 
    }
    
    func convertShiftDate() -> String? {
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        let date = dateFormatter.date(from: self.shift_date!)
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.string(from: date!)
    }
}
