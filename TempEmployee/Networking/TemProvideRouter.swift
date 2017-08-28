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
        case getSIALicence
        case taxesAndCharges
        case login(String,String)
        case create(Shift)
        case update(Shift)
        case postSlotId(Int,Int)
        case deleteShift(Int)
        case repostShift(Int)
        case postRating(Int,Int,Int,String) // jobseeker ID, shift ID, Rating Int, Review text
        case refreshToken()
        case updateFCMToken(token : String?)
  func asURLRequest() throws -> URLRequest {
   
    // create a variable of type HTTPMethod to set Api call type
    
    var method: HTTPMethod {
      switch self {
      case .get,.getSIALicence,.taxesAndCharges:
        return .get
      case .login,.create,.postSlotId,.postRating,.refreshToken:
        return .post
      case .deleteShift:
        return .delete
      case .update,.repostShift,.updateFCMToken:
        return .put
      }
    }
    
    // Params to be added in the api call
    // In case of GET and DELETE call return nil
    let params: ([String: Any]?) = {
      switch self {
      case .get ,.deleteShift,.repostShift,.taxesAndCharges:
        return nil
      case .getSIALicence:
        return nil
      case .login(let email, let password):
        return (Params.paramsForLogin(email: email, password: password, token: Messaging.messaging().fcmToken!))
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
    if Defaults[.hasUserRegistered]{
        
        let token = "Bearer " + Defaults[.accessToken]!
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
