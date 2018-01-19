//
//  ContractService.swift
//  Temp Provide
//
//  Created by Asad Khan on 11/5/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation


class Contract: Meta {
    
    var contractText : String!
    override init(jsonDict: JSONDict) {
        super.init(jsonDict: jsonDict)
        
        if success{
            
            contractText = jsonDict["data"]!["contract"] as! String
        }
    }
}

struct ContractService {
    
    func getJobContract(from employeeID:Int,completionHandler: @escaping (Result<Contract> ) -> Void){
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.getContract(empID: employeeID), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                //   print (response )
                let object = Contract(jsonDict: response as JSONDict)
                //    print("parsed data = ", object)
                
                completionHandler(.Success(object))
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }
    
    func sendJobContractTo( jobseekerID:Int,of shiftID:Int,contract:String,completionHandler: @escaping (Result<Meta> ) -> Void){
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.sendContract(jobseekerID: jobseekerID, shiftID: shiftID,contractText: contract), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                //   print (response )
                let object = Meta(jsonDict: response as JSONDict)
                //    print("parsed data = ", object)
                
                completionHandler(.Success(object))
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }

    
}

