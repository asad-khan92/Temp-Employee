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

enum TemProvideRouter: URLRequestConvertible {
    
    
  static let baseURLString = "https://devapi.temprovide.com/v1/"
  //static let authenticationToken = "Basic xxx"
    
        case get
        case getSIALicence
        case login(String,String)
        case create(Shift)
        case update(Shift)
        case postSlotId(Int,Int)
        case deleteShift(Int)
        case postRating(Int,Int,Int,String) // jobseeker ID, shift ID, Rating Int, Review text
    
  func asURLRequest() throws -> URLRequest {
   
    // create a variable of type HTTPMethod to set Api call type
    
    var method: HTTPMethod {
      switch self {
      case .get,.getSIALicence:
        return .get
      case .login,.create,.postSlotId,.postRating:
        return .post
      case .deleteShift:
        return .delete
      case .update:
        return .put
      }
    }
    
    // Params to be added in the api call
    // In case of GET and DELETE call return nil
    let params: ([String: Any]?) = {
      switch self {
      case .get ,.deleteShift:
        return nil
      case .getSIALicence:
        return nil
      case .login(let email, let password):
        return (Params.paramsForLogin(email: email, password: password))
      case .create(let shift),.update(let shift):
        return (Params.paramsForPostShift(data: shift))
      case .postSlotId(_ , let slotID):
        return (Params.paramsForSlotBooking(slotID: slotID))
      case .postRating(let jobseekerID, let shiftID, let Rating, let reviewText):
        return Params.paramsForPostRating(jobseekerID: jobseekerID, shiftID: shiftID, rating: Rating, review: reviewText)
      
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
        urlRequest.setValue("Bearer \(Defaults[.accessToken]!)", forHTTPHeaderField: "Authorization")
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
