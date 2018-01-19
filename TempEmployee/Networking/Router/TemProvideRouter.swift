//
//  TodoRouter.swift
//  grok101
//
//  Created by Christina Moulton on 2016-10-29.
//  Copyright © 2016 Teak Mobile Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyUserDefaults
import Firebase

enum TemProvideRouter: URLRequestConvertible {
    
    
  static let baseURLString = "https://devapi.temprovide.com/v1/"
  //static let authenticationToken = "Basic xxx"
    
        case get
        case registerEmployer(info:EmployerDetails)
        case getSIALicence
        case taxesAndCharges
        case login(creds:Credential)
        case create(job:Shift)
        case update(Shift)
        case postSlotId(Int,Int)
        case deleteShift(Int)
        case repostShift(Int)
        case postRating(Int,Int,Int,String) // jobseeker ID, shift ID, Rating Int, Review text
        case refreshToken()
        case updateFCMToken(token : String?)
        case postCompanyInfo(info:Company)
        case updateCompanyInfo(info:Company)
        case getCompanyInfo()
        case resendPhoneVerificationCode(empID: Int)
        case setEmployerActiveStatus(empID:Int)
        case getPostedShift
        case getCompletedShift
        case getCoveredShift
        case getExpiredShift
        case sendContract(jobseekerID: Int, shiftID : Int,contractText:String)
        case getContract(empID:Int)
        case forgotPassword(email:String)
    
  func asURLRequest() throws -> URLRequest {
   
    // create a variable of type HTTPMethod to set Api call type
    
    var method: HTTPMethod {
      switch self {
      case .get,.getSIALicence,.taxesAndCharges,.getCompanyInfo,.resendPhoneVerificationCode,.getPostedShift,.getCompletedShift,.getCoveredShift,.getContract,.getExpiredShift:
        return .get
      case .login,.create,.postSlotId,.postRating,.refreshToken,.registerEmployer,.postCompanyInfo,.setEmployerActiveStatus,.sendContract,.forgotPassword:
        return .post
      case .deleteShift:
        return .delete
      case .update,.repostShift,.updateFCMToken,.updateCompanyInfo:
        return .put
      }
    }
    
    // Params to be added in the api call
    // In case of GET and DELETE call return nil
    let params: ([String: Any]?) = {
      switch self {
      case .get ,.deleteShift,.repostShift,.taxesAndCharges,.getCompanyInfo,.resendPhoneVerificationCode,.getPostedShift,.getCompletedShift,.getCoveredShift,.getContract,.getExpiredShift:
        return nil
      case .getSIALicence:
        return nil
      case .login(let creds):
        return (Params.paramsForLogin(credential:creds, token: Messaging.messaging().fcmToken!))
      case .create(let shift),.update(let shift):
        return (Params.paramsForPostShift(data: shift))
      case .postSlotId(_ , let slotID):
        return (Params.paramsForSlotBooking(slotID: slotID))
      case .postRating(let jobseekerID, let shiftID, let Rating, let reviewText):
        return Params.paramsForPostRating(jobseekerID: jobseekerID, shiftID: shiftID, rating: Rating, review: reviewText)
        
      case .refreshToken:
        return (Params.paramsForRefreshingToken())
        
      case .updateFCMToken(let str):
        return Params.paramsForUpdatingFCMToken(token:str!)
      
      case .registerEmployer(let info):
        return Params.paramsForEmployerCreation(employerDetails : info)
        
      case .postCompanyInfo(let companyDetails):
        return Params.paramsForPostingCompanyInfo(info : companyDetails)
        
      case .updateCompanyInfo(let companyDetails):
        return Params.paramsForPostingCompanyInfo(info: companyDetails)
        
      case .setEmployerActiveStatus:
        return Params.paramForEmployerStatus()
        
      case .sendContract(let jobseekerID, let shiftID, let contractText):
        return Params.paramForSendingContractTo(jsID: jobseekerID, shiftID: shiftID,contract: contractText)
      case .forgotPassword(let email):
        return ["email":email]
        }
    }()
    let url: URL = {
      // build up and return the URL for each endpoint
      let relativePath: String?
      switch self {
      case .get:
        relativePath = Constants.EndPoints.Get.shifts
      case .getSIALicence:
        relativePath = Constants.EndPoints.Get.licences
      case .login:
        relativePath = Constants.EndPoints.Post.Login
      case .create:
        relativePath = Constants.EndPoints.Post.CreateShift
      case .postRating:
        relativePath = Constants.EndPoints.Post.JobSeekerRating
      case .postSlotId(let jobseekerID , _):
        print("\(jobseekerID)")
        relativePath = ""
      case .deleteShift(let id):
        relativePath = "\(Constants.EndPoints.Get.shifts)/\(id)"
      case .update(let shift):
        relativePath = "\(Constants.EndPoints.Get.shifts)/\(shift.id!)"
      case .repostShift(let id):
        relativePath = "\(Constants.EndPoints.Get.repostShift)/\(id)"
      case .taxesAndCharges:
        relativePath = Constants.EndPoints.Get.TaxAndCharges       
      case .refreshToken:
        relativePath = Constants.EndPoints.Post.refreshToken
      case .updateFCMToken:
         relativePath = Constants.EndPoints.Put.updateFcmToken
      case .registerEmployer:
        relativePath = Constants.EndPoints.Post.RegisterEmployer
      case .postCompanyInfo:
        relativePath = Constants.EndPoints.Post.ComapnyInfo
      case .updateCompanyInfo:
        relativePath = Constants.EndPoints.Put.ComapnyInfo
      case .getCompanyInfo:
        relativePath = Constants.EndPoints.Get.ComapnyInfo
      case .resendPhoneVerificationCode(let id):
        relativePath = Constants.EndPoints.Get.ResendVerificationCode + "\(id)"
      case .setEmployerActiveStatus(let id):
        relativePath = Constants.EndPoints.Post.EmployerActive + "\(id)"
      case .getPostedShift:
        relativePath = Constants.EndPoints.Get.PostedShifts
      case .getCompletedShift:
        relativePath = Constants.EndPoints.Get.CompletedShifts
      case .getCoveredShift:
        relativePath = Constants.EndPoints.Get.CoveredShifts
      case .getContract:
        relativePath = Constants.EndPoints.Get.Contract
      case .sendContract:
        relativePath = Constants.EndPoints.Post.SendContract
      case .getExpiredShift:
        relativePath = Constants.EndPoints.Get.ExpiredShifts
      case .forgotPassword:
        relativePath = Constants.EndPoints.Post.ForgotPassword
      }
        
        var url = URL(string: TemProvideRouter.baseURLString)!
      if let relativePath = relativePath {
        url = url.appendingPathComponent(relativePath)
      }
      return url
    }()
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method.rawValue
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = Defaults[.accessToken]{
        
        let token = "Bearer " + token//Defaults[.accessToken]!
        print(token)
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
    }
    var encoding : ParameterEncoding
    
    encoding = JSONEncoding.default
    
//    switch self {
//    case .deleteShift:
//        encoding = URLEncoding.default
//    default:
//         encoding = JSONEncoding.default
//    }
    
    return try encoding.encode(urlRequest, with: params)
  }
}
