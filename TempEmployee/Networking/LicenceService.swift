//
//  LicenceService.swift
//  TempEmployee
//
//  Created by kashif Saeed on 06/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation

class SIALicenc:Meta{
    
    var licences = [Licence]()
    
    override init(jsonDict: JSONDict) {
        
        super.init(jsonDict: jsonDict)
        
        if self.success{
            let licenceArray = jsonDict["data"] as? [[String:Any]]
            
            for licence in licenceArray!{
                
                let licenceObject = Licence(id: licence["id"] as! NSNumber, license_name: licence["license_name"] as! String)
                
                licences.append(licenceObject)
                
            }
        }
        
    }
    
}
struct LicenceService {
    
    
    func fetchSIALicence(with completionHandler: @escaping (Result<SIALicenc> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.getSIALicence, completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                let object = SIALicenc(jsonDict: response as JSONDict)
                print("parsed data = ", object)
                completionHandler(.Success(object))
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        

    }
}
