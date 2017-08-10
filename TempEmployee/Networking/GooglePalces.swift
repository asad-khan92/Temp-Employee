//
//  GooglePalces.swift
//  TempEmployee
//
//  Created by kashif Saeed on 08/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation

extension AddShiftController {
    
    
   // https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=YOUR_API_KEY
    //https://maps.googleapis.com/maps/api/place/autocomplete/json
    
    //https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJrTLr-GyuEmsRBfy61i59si0&key=YOUR_API_KEY
    func fetchAutocompletePlaces(_ keyword:String , completionHandler:@escaping (NSArray?) -> Void) {
        
        let urlString = "\(Constants.GoogleAutoComplete.baseURLString)?key=\(Constants.GoogleAutoComplete.googleMapsKey)&input=\(keyword)"
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                            
                            if let status = result["status"] as? String{
                                if status == "OK"{
                                    if let predictions = result["predictions"] as? NSArray{
                                        var locations = [String]()
                                        for dict in predictions as! [NSDictionary]{
                                            locations.append(dict["description"] as! String)
                                        }
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            completionHandler(predictions)
                                            self.cell?.jobAddressField.autoCompleteStrings = locations
                                        })
                                        return
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.cell?.jobAddressField.autoCompleteStrings = nil
                            })
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }
    
    /*----------------------*/
    
    func fetchLatLongByPlaceID(_ ID:String , completionHandler:@escaping ([String:Any]?) -> Void) {
        //https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJrTLr-GyuEmsRBfy61i59si0&key=YOUR_API_KEY
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(ID)&key=\(Constants.GoogleAutoComplete.googleMapsKey)"
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                            
                            if let status = result["status"] as? String{
                                if status == "OK"{
                                    if let locationInfo = result["result"] as? [String:Any]{
                                        
                                        if let geometry = locationInfo["geometry"] as? [String:Any]{
                                            
                                            if let location =  geometry["location"] as? [String:Any]{

                                                DispatchQueue.main.async(execute: { () -> Void in
                                                            completionHandler(location)
                                           
                                                        })
                                            }
                                    }
                                        return
                                    }
                                }
                            }
                            
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }
    
}
