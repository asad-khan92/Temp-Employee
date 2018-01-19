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
import IQKeyboardManagerSwift

enum ContactType :Int{
    
    case call
    case whatsApp
}
class ViewShiftInfoController: UIViewController {

    @IBOutlet weak var InformationView: IQPreviousNextView!
    @IBOutlet weak var applicantsContainerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backPressed: UIButton!
    @IBOutlet weak var shiftCostLabel: UILabel!
    @IBOutlet weak var addresslabel: UILabel!
    @IBOutlet weak var jobseekerImageView: UIImageView!
    @IBOutlet weak var timendHourLabel: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var rollLabel: UILabel!
    @IBOutlet weak var editPressed: UIButton!
    
    var shift: Shift!
    var selectedPointAnnotation:MKPointAnnotation?
    var applicantDetail : ApplicantDetail!
    var applicantListController : ApplicantListController!
    //var contractSent : Bool!
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
        
       
        if self.shift.jobSeekers != nil {
            self.editPressed.isHidden = true
        }
        
         applicantListController = self.storyboard?.instantiateViewController(withIdentifier: "ApplicantListController") as! ApplicantListController
        applicantListController.jobID = shift.id
        applicantListController.jobseekerArray = shift.jobSeekers!
        applicantListController.delegate = self
        applicantListController.contractSend = false
        if shift.shift_status == ShiftStatus.CONTRACTSENT{
            applicantListController.contractSend = true
        }
        addChildViewController(applicantListController) // Calls the viewWillAppear method of the ViewController you are adding
        applicantListController.view.frame = self.applicantsContainerView.bounds
        applicantsContainerView.addSubview(applicantListController.view)
        
        applicantListController.didMove(toParentViewController: self) // Call the viewDidAppear method of the ViewController you are adding
        
    }
    @IBAction func ratingButtonPressed(_ sender: UIButton) {
        
//        if self.shift.shift_status != .SHIFT_TO_BE_COVERED{
//            self.errorAlert(description: "Sorry!, you can't rate untill the job is finish")
//        }else{
//            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//            let rateVC : RateViewController = storyboard.instantiateViewController()
//            rateVC.shift = self.shift
//            self.navigationController?.pushViewController(rateVC, animated: true)
//        }
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    @IBAction func backPressed(_ sender: Any) {
        
        if applicantDetail != nil {
            applicantDetail.removeFromSuperview()
            applicantDetail = nil
            return
        }
        if applicantsContainerView.isHidden{
            
            applicantsContainerView.isHidden = false
            
            self.InformationView.isHidden = false
            
            applicantDetail.removeFromSuperview()
            return
        }
      let  _ =  self.navigationController?.popToRootViewController(animated: true)
    }
    
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
    
    func showContractControllertTo(jobseeker : JobSeeker, jobID :Int){
        
        let dest = self.storyboard?.instantiateViewController(withIdentifier: "ContractViewController") as! ContractViewController
        dest.shiftID = jobID
        dest.jobseeker = jobseeker
        dest.delegate = self
        present(dest, animated: true, completion: nil)
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
extension ViewShiftInfoController:ApplicantListControllerDelegate{
    
    
    
    
    func showApplicantDetail(applicant: JobSeeker) {
        
         applicantDetail = Bundle.main.loadNibNamed("ApplicantDetail", owner: self, options: nil)?.first as! ApplicantDetail?
        applicantDetail?.applicant =  applicant
         applicantDetail.jobSeekerAlreadyHired = false
        if shift.shift_status == .CONTRACTSENT{
            applicantDetail.jobSeekerAlreadyHired = true
        }
        applicantDetail.delegate = self
        applicantDetail?.frame = self.InformationView.frame
        applicantDetail?.frame.origin = CGPoint.init(x: 0.0, y: self.InformationView.frame.origin.y - 80)
        
        view.addSubview(applicantDetail!)
    }
}

extension ViewShiftInfoController:ContractSentDelegate{
    
    func contractSentTo(jobseeker: String) {
        applicantDetail?.removeFromSuperview()
        applicantListController.filterApplicantList(applicantID: jobseeker)
        
    }
}
extension ViewShiftInfoController:ApplicantDetailDelegate{
    func hire(jobseeker: JobSeeker) {
        self.showContractControllertTo(jobseeker: jobseeker,jobID :shift.id)
    }
}
