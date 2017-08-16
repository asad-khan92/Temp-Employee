//
//  CreateShiftService.swift
//  TempEmployee
//
//  Created by kashif Saeed on 08/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation


class Charges:Meta{
    
    var valueAddedTax : Double!
    var tempProvideFee : Double!
    var cardCharges : Double!
    
    override init(jsonDict: JSONDict) {
        
        super.init(jsonDict: jsonDict)
        
        if self.success{
            let chargesDic = jsonDict["data"] as? [String:Any]
            
           /// for charge in chargesArray!{
                
               // let licenceObject =  licence["id"] as! NSNumber, license_name: licence["license_name"] as! String)
            
                tempProvideFee = Double.init(chargesDic?["temp_provide_fee"] as! String)
                valueAddedTax  =  Double.init(chargesDic?["vat"] as! String)
                cardCharges =  Double.init(chargesDic?["card_charge"] as! String)
                
            //}
        }
        
    }
    
}


struct CreateShift {
    

    
    func getCharges(completionHandler: @escaping (Result<Charges> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.taxesAndCharges, completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                let object = Charges(jsonDict: response as JSONDict)
                print("parsed data = ", object)
                completionHandler(.Success(object))
                /*let success = response["meta"]!["success"] as? Bool
                 if success! {
                 
                 
                 }else{
                 
                 }*/
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }
    
    
    func createShift(shift:Shift ,completionHandler: @escaping (Result<Meta> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.create(shift), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                let object = Meta(jsonDict: response as JSONDict)
                print("parsed data = ", object)
                completionHandler(.Success(object))
                /*let success = response["meta"]!["success"] as? Bool
                 if success! {
                 
                 
                 }else{
                 
                 }*/
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }
    
    func updateShift(shift:Shift ,completionHandler: @escaping (Result<Meta> ) -> Void) {
        
        NetworkManager.shared.callServer(with_request: TemProvideRouter.update(shift), completionHandler: {result in
            
            switch result {
                
            case .Success(let response):
                print (response )
                let object = Meta(jsonDict: response as JSONDict)
                print("parsed data = ", object)
                completionHandler(.Success(object))
                /*let success = response["meta"]!["success"] as? Bool
                 if success! {
                 
                 
                 }else{
                 
                 }*/
                
            case .Failure(let error):
                completionHandler(.Failure(error))
            }
            
        })
        
    }
}
