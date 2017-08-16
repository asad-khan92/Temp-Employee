//
//  NetworkManager.swift
//  Temp Provide
//
//  Created by kashif Saeed on 15/05/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyUserDefaults

typealias SuccessHandler<T> = (Result<T>) -> Void

enum NetworkError : Error {
    case noNetwork
    case serverError(String)
    case incorrectUrl(String)
    case userCancelled
    case invalidCredentials
    case tokenExpired
    var localizedDescription : String {
        
        switch self {
        case .noNetwork:
            return "Please check if you are connected to internet."
        case .serverError(let error):
            return error
        case .incorrectUrl(let url):
            return "The url \(url) is not correct"
        case .userCancelled: // for facebook login error
            return "Request cancelled"
        case .invalidCredentials:
            return "Incorrect email or password"
        case .tokenExpired:
            return "access_denied"
        }
    }
}

enum Result<T> {
    case Success(T)
    case Failure(Error)
}

class NetworkManager {

    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    
    static let shared = NetworkManager()
    
    // MARK: Local Variable
    
    let sessionManager : SessionManager = SessionManager()
    let oauthHandler : OAuth2Handler = OAuth2Handler(
        clientID: "1",
        baseURLString: TemProvideRouter.baseURLString,
        accessToken: Defaults[.accessToken] ?? "",
        refreshToken: Defaults[.refreshToken] ?? ""
    )

}
extension NetworkManager {
    
     func callServer(with_request request: URLRequestConvertible, completionHandler: @escaping (Result<[String:Any]>) -> Void){
        
        sessionManager.request(request).validate().responseJSON { response in
            if let errorData = response.result.error {
                completionHandler(.Failure(errorData))
                return
            }
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as?  [String: Any]
                    completionHandler(.Success(json!))
                }catch{
                    
                }
            }

        }
        
    }
}



