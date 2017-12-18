//
//  CompanyServices.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/16/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation



struct CompanyServices {
    
    func postCompany( Info:Company ,completionHandler: @escaping (Result<Meta> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.postCompanyInfo(info: Info), completionHandler: {result in
            
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
    
    func updateCompany( Info:Company ,completionHandler: @escaping (Result<Meta> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.updateCompanyInfo(info: Info), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                let object = Code(jsonDict: response as JSONDict)
                print("parsed data = ", object)
                completionHandler(.Success(object))
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }
    
    func getCompany(Info : Company, completionHandler: @escaping (Result<Meta> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.getCompanyInfo(), completionHandler: {result in
            
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
