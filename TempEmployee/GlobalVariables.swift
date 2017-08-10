//
//  GlobalVariables.swift
//  Temp Provide
//
//  Created by kashif Saeed on 19/05/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation

struct Constants {
    
    static let appName: String                          = "Temp Employee"
    
    struct Notifications {
        
        static let shiftPosted: String                  = "shiftPostedSuccessfully"
        static let refreshShiftsList: String            = "refreshShifts"
    }
    
    struct EndPoints {
        struct Post {
            static let Login : String                   = "employers/login"
            static let LicenceDetails : String          = "employers/licenseDetails"
            static let CreateShift : String             = "employers/shifts"
            static let JobSeekerRating : String         = "employers/jobSeekerRating"
        }
        
        
        struct Get {
            
            static let shifts : String                      = "employers/shifts"
            static let repostShift : String                 = "employers/repostShift"
            static let licences : String                    = "licenseTypes"
            static let TaxAndCharges :String                = "settings"
        }
        /**
         Repeats a string `times` times.
         
         - Parameter id:   The job seekeer id.
         - Parameter endpoint: GET / POST Method name.
         - Returns: A completed URL string got registered job seeker.
         */
        
        var getAllInterviewSlots: (Int,String) -> String = EndPoints.createJobseekerURL
        
        static func createJobseekerURL(userID:Int,endpoint:String) -> String {
            
            return "jobSeekers/\(userID)/\(endpoint)"
        }
    }
    
    struct Employer {
        static let accessToken : String                 = "access_token"
        static let accessTokenExpireIn : String         = "accessTokenExpireIn"
        static let licencePosted : String               = "licencePosted"
        static let email : String                       = "employer_email"
        static let password : String                    = "employer_password"
        
         static let Registered : String                 = "userRegistered"
         static let LicencesUploaded : String           = "licencesUploaded"
         static let ProfilePicUploaded : String         = "profilePicUploaded"
         static let AccountDetailsUploaded : String     = "accountDetailsUploaded"
         static let InterviewSlotBooked : String        = "interviewSlotBooked"
        
        static let scheduledInterviewDate : String      = "scheduledInterviewDate"
        static let scheduledInterviewTime : String      = "scheduledInterviewTime"
        static let scheduledInterviewAddress : String   = "scheduledInterviewAddress"
    }
    
    struct licenceConstants {
        static let id : String                          = "id"
        static let title : String                       = "title"
        
    }
    
    struct S3Credentials {
        static let secretkey : String                   = "7mKulZ++s1toDiMgjVUcKzQv3dm+CrKBk9BSgzNW"
        static let accessKey : String                   = "AKIAJIXK6GZMBVX5FWDA"
        static let S3_BUCKET_NAME                       =  "gl-lms"
        static let S3_BUCKET_URL                        = "http://gl-lms.s3.amazonaws.com/"
        static let profilePic: String                   = "Profile.png"
        
    }
    
    struct Shift {
        static let defaultPrice : Int                        = 8
        static let defaultHours : Int                        = 8
        static let time : [String]                           = ["01:00 AM","01:30 AM","02:00 AM","02:30 AM","03:00 AM","03:30 AM","04:00 AM","04:30 AM","05:00 AM","05:30 AM","06:00 AM","06:30 AM","07:00 AM","07:30 AM","08:00 AM","08:30 AM","09:00 AM","09:30 AM","10:00 AM","10:30 AM","11:00 AM","11:30 AM","12:00 AM","12:30 PM","01:00 PM","01:30 PM","02:00 PM","02:30 PM","03:00 PM","03:30 PM","04:00 PM","04:30 PM","05:00 PM","05:30 PM","06:00 PM","06:30 PM","07:00 PM","07:30 PM","08:00 PM","08:30 PM","09:00 PM","09:30 PM","10:00 PM","10:30 PM","11:00 PM","11:30 PM","12:00 PM","12:30 AM"]
    }
    
    struct GoogleAutoComplete {
        static let googleMapsKey : String = "AIzaSyAhpwK4UEihJFgM68PG770r9zTzD4tKtmQ"
        static let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    }
}
