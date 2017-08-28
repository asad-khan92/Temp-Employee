//
//  ViewShiftInfoController.swift
//  TempEmployee
//
//  Created by kashif Saeed on 11/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

enum ContactType :Int{
    
    case call
    case whatsApp
}
class ViewShiftInfoController: UIViewController {

    @IBOutlet var starButtons: [UIButton]!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backPressed: UIButton!
    @IBOutlet var ratingStars: [UIButton]!
    @IBOutlet weak var shitCovererView: UIImageView!
    @IBOutlet weak var jobRollLabel: UILabel!
    @IBOutlet weak var jobseekerName: UILabel!
    @IBOutlet weak var shiftCostLabel: UILabel!
    @IBOutlet weak var addresslabel: UILabel!
    @IBOutlet weak var jobseekerImageView: UIImageView!
    @IBOutlet weak var timendHourLabel: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var rollLabel: UILabel!
    @IBOutlet weak var callButtonPressed: UIButton!
    
    @IBOutlet weak var shiftCovererView: UIView!
    var shift: Shift!
    var selectedPointAnnotation:MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let lat = self.shift.lat ,let lng = self.shift.lng{
            let coord:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
            
            self.addAnnotation(coord, address: self.shift.address)
            self.mapView.setCenterCoordinate(coord, zoomLevel: 12, animated: true)
        }
        self.rollLabel.text = self.shift.role?.uppercased()
        self.datelabel.text = self.shift.shift_date!
        self.timendHourLabel.text = "\(self.shift.from_time!) - \(self.shift.shift_hours!)"
        self.addresslabel.text = self.shift.address
        
        self.shiftCostLabel.text = "£\(self.shift.totalCost!)"
        
       
        if self.shift.assigned_job_seeker_id == nil {
            self.editPressed.isHidden = true
        }
        if self.shift.assigned_job_seeker_id != nil {
            
            self.shiftCovererView.isHidden = false
            self.jobseekerName.text = self.shift.jobSeeker?.username?.uppercased()
            self.jobRollLabel.text = self.shift.role?.uppercased()
            
            if let imagePath = self.shift.jobSeeker?.image_path{
            self.shitCovererView.sd_setImage(with: URL(string: imagePath))
            }
            
            if let rating = self.shift.jobSeeker?.average_rating{
                
               var r =  rating
                
                for (index,button) in starButtons.enumerated()
                {
                    if index == r{
                        break
                    }
                    button.isSelected = true
                }
                
            }
            
        }
    }
    @IBAction func ratingButtonPressed(_ sender: UIButton) {
        
        if self.shift.shift_status != .SHIFT_TO_BE_COVERED{
            self.errorAlert(description: "Sorry!, you can't rate untill the job is finish")
        }else{
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let rateVC : RateViewController = storyboard.instantiateViewController()
            rateVC.shift = self.shift
            self.navigationController?.pushViewController(rateVC, animated: true)
        }
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        
        if self.shift.jobSeeker?.phone == nil{
            
            self.errorAlert(description: "\(self.shift.jobSeeker?.username) have not provided his contact number")
            return
        }
        if let contactNumber = self.shift.jobSeeker?.phone!{
            
            let str = "tel:\(contactNumber)"
            self.openSharedURl(str:str , type: .call)
            
            
        }
        
        
    }
    @IBAction func whatsAppButtonPressed(_ sender: Any) {
        
        
       
        if self.shift.jobSeeker?.phone == nil{
            
            self.errorAlert(description: "\(self.shift.jobSeeker?.username) have not provided his WhatsApp contact")
            return
        }
        if let contactNumber = self.shift.jobSeeker?.phone!{
            
            var stringURL : String
            if contactNumber.hasPrefix("+") ||  contactNumber.hasPrefix("+44"){
                
                 let number = contactNumber.replacingOccurrences(of: "+", with: "")
                 stringURL = "https://api.whatsapp.com/send?phone=\(number)&text=hello"
            }else{
                stringURL = "https://api.whatsapp.com/send?phone=44\(contactNumber)&text=hello"
            }
            
            self.openSharedURl(str:stringURL , type: .whatsApp)
        
        
  
        }

    }
    func openSharedURl(str:String , type:ContactType) {
        
         let urlString = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlString!)
        if url == nil{
            
            return
        }
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: { reult in
                
                print("\(url) \(reult)")
            })
            
        }

    }
    @IBAction func backPressed(_ sender: Any) {
      let  _ =  self.navigationController?.popToRootViewController(animated: true)
    }
    @IBOutlet weak var editPressed: UIButton!
    @IBAction func editPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard.init(name: "AddShift", bundle: nil)
        
        let addShiftVC : AddShiftController = storyboard.instantiateViewController()
        addShiftVC.shift = self.shift
        addShiftVC.isEditingShift = true
        self.navigationController?.pushViewController(addShiftVC, animated: true)
    }

    
    fileprivate func addAnnotation(_ coordinate:CLLocationCoordinate2D, address:String?){
        if let annotation = selectedPointAnnotation{
            mapView.removeAnnotation(annotation)
        }
        
        selectedPointAnnotation = MKPointAnnotation()
        selectedPointAnnotation!.coordinate = coordinate
        selectedPointAnnotation!.title = address
        mapView.addAnnotation(selectedPointAnnotation!)
    }
}


extension ViewShiftInfoController:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.image = UIImage(named:"Map Marker")!
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
        
    }
}

