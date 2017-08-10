//
//  AddShiftController.swift
//  TempEmployee
//
//  Created by kashif Saeed on 04/06/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import DropDown
import SwiftValidator
import AFDateHelper
import PKHUD

class AddShiftController: UIViewController {

    
    var price : Int? {
        
        didSet{
            
            self.cell?.pricePerHourField.text = "£\(price!)"
        }
    }
    
    var hours : Int? {
        
        didSet{
            
            self.cell?.hoursField.text = "\(hours!) hr"
            
        }
    }
    
    var licecnceField : UITextField!
    var textFieldTapRecognizer :UITapGestureRecognizer?
    var cell : AddShiftCell?
    var licences  =  [Licence]()
    var selectedLicences  =  [Licence]()
    var shift : Shift?
    var dataTask:URLSessionDataTask?
    var selectedPointAnnotation:MKPointAnnotation?
    var coordinate : CLLocationCoordinate2D?
    var isEditingShift:  Bool! = false
    
    var dropDown : DropDown!
    let validator = Validator()
    let timeArray = Constants.Shift.time
    var predictions : NSArray!
    
    // set initial location in London
    let initialLocation = CLLocation(latitude: 51.50699, longitude: -0.13606)
    let regionRadius: CLLocationDistance = 2000
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rollField: UITextField!
    @IBOutlet weak var address: UITextView!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dropDown = DropDown()
        
        self.navigationController?.navigationBar.isHidden = true
        self.tableView.dataSource   = self
        self.tableView.delegate     = self
        self.mapView.delegate = self
        self.FetchAllSIALicences(service: LicenceService())
        
        centerMapOnLocation(location: initialLocation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isEditingShift{
            
            
        }else{
            
            self.price = Constants.Shift.defaultPrice
            self.hours = Constants.Shift.defaultHours
        }
        
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func clearPrefilledData() {
        
        self.cell?.licenceRequiredField.text = ""
        self.cell?.dateField.text = ""
        self.cell?.jobRollField.text = ""
        self.cell?.startTimeField.text = ""
        self.cell?.pricePerHourField.text = ""
        
        self.cell?.addressErrorLabel.text = ""
        self.cell?.rollErrorLabel.text = ""
        self.cell?.requiredLicenceErrorLabel.text = ""
        self.cell?.priceErrorLabel.text = ""
        
        self.cell?.licenceView.subviews.forEach({ $0.removeFromSuperview() })
        self.coordinate = nil
        self.centerMapOnLocation(location: self.initialLocation)
    }
}
extension AddShiftController: UITableViewDataSource, UITableViewDelegate ,ValidationDelegate , UITextFieldDelegate,UIGestureRecognizerDelegate,MKMapViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier:"AddShiftCell" , for: indexPath) as! AddShiftCell
       
        
        // save cell instance as tablview is only use to handle vertical scrolling 
        // and there will always be a single cell
        self.cell = cell
        
        
        if self.shift != nil{
            cell.jobRollField.text = self.shift?.role
            cell.jobAddressField.text = self.shift?.address
            cell.hoursField.text = self.shift?.shift_hours
            cell.pricePerHourField.text = "\(self.shift!.price_per_hour!)"
            cell.startTimeField.text = self.shift?.from_time
            
            if let dateStr = self.shift?.shift_date{
                
                // server sends date in yyyy-MM-dd format when fetched
                // we need date in dd MMM yyyy
                // covert date string to date coz it's in dd MMM yyyy format
                
                let d = Date(fromString:dateStr , format: DateFormatType.custom("yyyy-MM-dd"))
                
                cell.dateField.text = d?.toString(format:DateFormatType.custom("dd MMM yyyy"))
                
                // set it again becuse server takes date in "dd Mm yyyy format when updating or creating"
                self.shift?.shift_date = cell.dateField.text
            }
            
            
            if self.shift?.lat != nil , self.shift?.lng != nil{
                
                self.coordinate = CLLocationCoordinate2DMake((self.shift?.lat!)!, (self.shift?.lng!)!)
            }
            for lic in (self.shift?.required_licenses)!{
               // self.selectedLicences.append(lic)
                self.addTagView(selectedLicenceObject: lic)
            }
            
            //self.fetchAutocompletePlaces(cell.jobAddressField.text!)
            
        }else{
       
            cell.pricePerHourField.text = "£\(Constants.Shift.defaultPrice)"
            cell.hoursField.text = "\(Constants.Shift.defaultHours) hr"
        }
        // Validation Rules are evaluated from left to right.
        validator.registerField(cell.jobAddressField , errorLabel:cell.addressErrorLabel  , rules: [RequiredRule()])
        
        validator.registerField(cell.jobRollField , errorLabel:cell.rollErrorLabel, rules: [RequiredRule()])
       
        validator.registerField(cell.startTimeField , errorLabel:cell.startTimeErrorLabel, rules: [RequiredRule()])
        validator.registerField(cell.hoursField , errorLabel:cell.hoursErrorLabel, rules: [RequiredRule()])
        validator.registerField(cell.dateField , errorLabel:cell.dateErrorLabel, rules: [RequiredRule()])
        validator.registerField(cell.pricePerHourField , errorLabel:cell.priceErrorLabel, rules: [RequiredRule()])
        
        
        //cell.shiftStatus = shift.
        cell.nextButton.addTarget(self, action: #selector(nextButtonPressed),for: .touchUpInside)
        cell.cancelButton.addTarget(self, action: #selector(cancelButtonPressed),for: .touchUpInside)
        
        cell.addLicenceButton.addTarget(self, action: #selector(addLicence(_:)),for: .touchUpInside)
        
        cell.startTimeDropDownButton.addTarget(self, action: #selector(showStartDropDownMenu(_:)),for: .touchUpInside)
        cell.dateDropDownButton.addTarget(self, action: #selector(showDateDropDownMenu(_:)),for: .touchUpInside)
        
        cell.hoursMinusButton.addTarget(self, action: #selector(minusHours),for: .touchUpInside)
        cell.hoursPlusButton.addTarget(self, action: #selector(plusHours),for: .touchUpInside)
        
        cell.pricePlusButton.addTarget(self, action: #selector(plusPrice),for: .touchUpInside)
        cell.priceMinusButton.addTarget(self, action: #selector(minusPrice),for: .touchUpInside)
        
        cell.licenceRequiredField.delegate = self
       // cell.jobAddressTxtView.delegate = self
        cell.jobRollField.delegate = self
        cell.hoursField.delegate = self
        cell.pricePerHourField.delegate = self
        cell.dateField.delegate = self
        cell.startTimeField.delegate = self

        self.licecnceField = cell.licenceRequiredField
        
        //self.configureTextField(autocompleteTextfield: cell.jobAddressField)
        
        textFieldTapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(textFieldTapGestureAction(_:)))
        textFieldTapRecognizer?.delegate = self
             cell.licenceRequiredField.addGestureRecognizer(textFieldTapRecognizer!)
        
        cell.jobAddressField.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        cell.jobAddressField.autoCompleteTextFont = UIFont(name: "Lato-Light", size: 12.0)!
        cell.jobAddressField.autoCompleteCellHeight = 35.0
        cell.jobAddressField.maximumAutoCompleteCount = 20
        cell.jobAddressField.hidesWhenSelected = true
        cell.jobAddressField.hidesWhenEmpty = true
        cell.jobAddressField.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "Lato-Bold", size: 12.0)
        cell.jobAddressField.autoCompleteAttributes = attributes
        self.handleTextFieldInterfaces(autocompleteTextfield: cell.jobAddressField)
        
        
        
        
        
        return cell
    }
    fileprivate func configureTextField(autocompleteTextfield:AutoCompleteTextField){
       
        
        
    }
    fileprivate func handleTextFieldInterfaces(autocompleteTextfield:AutoCompleteTextField){
        autocompleteTextfield.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces("\(text) in United Kingdom",completionHandler: {predictionsArray in
                    
                    self?.predictions = predictionsArray!
                    
                    print((self?.predictions.firstObject as! [String:Any])["place_id"] as! String)
                })
            }
        }
        
        autocompleteTextfield.onSelect = {[weak self] text, indexpath in
            
            let plcaeID = (self?.predictions.object(at: indexpath.row) as! [String:Any])["place_id"] as! String
            
            
            self?.fetchLatLongByPlaceID(plcaeID, completionHandler: {result in
                
                let lat = result?["lat"] as! NSNumber
                let long = result?["lng"] as! NSNumber
                
                let coord = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
                self?.addAnnotation(coord, address: text)
                self?.mapView.setCenterCoordinate(coord, zoomLevel: 12, animated: true)
                self?.coordinate = coord
                
            })
            
            
//            Location.geocodeAddressString(text, completion: { (placemark, error) -> Void in
//                if let coordinate = placemark?.location?.coordinate {
//                    self?.addAnnotation(coordinate, address: text)
//                    self?.mapView.setCenterCoordinate(coordinate, zoomLevel: 12, animated: true)
//                    self?.coordinate = coordinate
//                }
//            })
        }
    }
    
    //MARK: - Private Methods
    fileprivate func addAnnotation(_ coordinate:CLLocationCoordinate2D, address:String?){
        if let annotation = selectedPointAnnotation{
            mapView.removeAnnotation(annotation)
        }
        
        selectedPointAnnotation = MKPointAnnotation()
        selectedPointAnnotation!.coordinate = coordinate
        selectedPointAnnotation!.title = address
        mapView.addAnnotation(selectedPointAnnotation!)
    }
    
    func textFieldTapGestureAction(_ sender : UITapGestureRecognizer)  {
    }
    
    func nextButtonPressed()  {

        validator.validate(self)
    }
    
    func cancelButtonPressed()  {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func addLicence(_ sender : UIButton)  {
       

        let namesArray = self.licences.flatMap{$0.license_name}
        let dropDown =  self.showDropDownMenu(onView: sender, dataForDropDownMenu:namesArray)
        dropDown.show()
        
        // Action triggered on selection
        dropDown.selectionAction = {  (index: Int, item: String) in
            let  filteredArray = self.selectedLicences.filter{$0.id.intValue == self.licences[index].id as Int}
            print(filteredArray)
            if filteredArray.count == 1{
                return
            }
            self.cell?.licenceRequiredField.text = item
            self.addTagView(selectedLicenceObject:self.licences[index])
        }
    }
    func addTagView(selectedLicenceObject : Licence) {
        
        // this logic is bullshit can crash if any change made in addTagview method
        // be very cardfull changing anything in that method
        // TO DO : NEED TO CHANGE IT ASAP-
        var index = self.selectedLicences.count
        index -= 1
        self.cell?.licenceView.addSubview((self.cell?.licenceView.addTagView(licence: selectedLicenceObject, callBackHandler: self, callback: #selector(self.removeLicence(_:)), lastTagIndex:index  , previousTags :(self.cell?.licenceView.subviews)! ))!)
        self.selectedLicences.append(selectedLicenceObject)
        
        
        
    }
    func showStartDropDownMenu(_ sender : UIButton)  {
       
        
        let dropDown =  self.showDropDownMenu(onView: sender, dataForDropDownMenu: self.timeArray)
        dropDown.show()
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.cell?.startTimeField.text = item
        }
        
        
        
    }
    func showDateDropDownMenu(_ sender : UIButton)   {
        
       
        let calendar  : Calendar    =   Calendar(identifier: .gregorian)
        let startDate : Date        =   Date.init(timeIntervalSinceNow: 0)
        let endDate   : Date        =   Date.init(timeIntervalSinceNow: 24*60*60*14-1)
        
       let dateRange = calendar.dateRange(start: startDate, end: endDate, stepUnits: .day, stepValue: 1)
        
        let datesInRange = Array(dateRange)
    
        let stringDates = datesInRange.map{$0.toString(format:DateFormatType.custom("dd MMM yyyy"))}
       let dropDown =  self.showDropDownMenu(onView: sender, dataForDropDownMenu: stringDates)
        
        dropDown.show()
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
        
            self.cell?.dateField.text = item
        }
    }
    func minusHours()  {
        self.hours! -= 1
    }
    func plusHours()  {
        self.hours! += 1
    }
    func plusPrice()  {
        self.price! += 1
    }
    func minusPrice()  {
       self.price! -= 1
    }
    
    func showDropDownMenu(onView:UIView , dataForDropDownMenu : [String]) -> DropDown {
        
        self.tableView.endEditing(true)
        dropDown.anchorView = onView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = dataForDropDownMenu
        
        return dropDown
       
        }
    
    func removeLicence(_ sender:UIButton)  {
        self.selectedLicences = self.selectedLicences.filter{$0.id.intValue != sender.tag}
        self.cell?.licenceRequiredField.text = ""
        sender.superview?.removeFromSuperview()

    }
    func validationSuccessful() {
        // after user have corrected all the fields remove the error labels text
        // removeErrorLabelText()
        
        if self.selectedLicences.count == 0 {
            
            self.cell?.requiredLicenceErrorLabel.text = "Select an SIA Licence"
            return
        }
        if self.coordinate == nil{
            
            self.cell?.addressErrorLabel.text = "Please select a location from suggestions"
            return
        }
        let price = self.cell?.pricePerHourField.text?.replacingOccurrences(of: "£", with: "")
        let hour = self.cell?.hoursField.text?.replacingOccurrences(of: "hr", with: "").replacingOccurrences(of: " ", with: "")
        //hour?.trimmingCharacters(in: " ")
        guard let coord  = self.coordinate else {
            return
        }
//        let latitude = "\(coord.latitude)"
//        let longitude = "\(coord.longitude)"
        if self.isEditingShift! {
            
            self.shift?.role = self.cell?.jobRollField.text
            self.shift?.address = self.cell?.jobAddressField.text
            self.shift?.from_time = self.cell?.startTimeField.text
            self.shift?.shift_hours = hour
            self.shift?.price_per_hour = Float.init(price!)
            self.shift?.shift_date = self.cell?.dateField.text
            self.shift?.required_licenses = self.selectedLicences
            self.shift?.lat = coord.latitude
            self.shift?.lng = coord.longitude
            
        }else{
            self.shift = Shift(role: self.cell?.jobRollField.text, from_time: self.cell?.startTimeField.text, shift_hours:hour , address: self.cell?.jobAddressField.text, price_per_hour:Float.init(price!) , shift_date: self.cell?.dateField.text, required_licenses: self.selectedLicences,latitude:coord.latitude,longitude:coord.longitude)
        }
        
        self.moveToNextStep()
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (_, error) in errors {
            /* if let field = field as? UITextField {
             field.layer.borderColor = UIColor.red.cgColor
             field.layer.borderWidth = 1.0
             }*/
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
            error.errorLabel?.textColor = UIColor.red
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        if textField == self.licecnceField{
            self.resignFirstResponder()
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        //Return YES if it's textFieldTapRecognizer else return NO.
            return (gestureRecognizer == textFieldTapRecognizer);
    }
   
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

// NETWORKING
//
//
extension AddShiftController{
    
    
    
    func FetchAllSIALicences(service:LicenceService) {
        
        HUD.show(.progress,onView: self.view)
        
        service.fetchSIALicence(with: {result in
            
            switch result{
                
            case .Success(let response):
                print(response)
                HUD.flash(.success, delay: 0.0)
                if response.success{
                    self.licences = response.licences
                }else{
                    HUD.flash(.error, delay: 0.0)
                    self.errorAlert(description: response.message)
                }
            case .Failure(let error):
                HUD.flash(.error, delay: 0.0)
                self.errorAlert(description: error.localizedDescription)
                print(error)
            }
            
            
        })
    }
    
    func moveToNextStep()  {
        
        let storyboard = UIStoryboard.init(name: "AddShift", bundle: nil)
        
        let shiftDetailVC : ShiftDetailController = storyboard.instantiateViewController()
        
        shiftDetailVC.shift = self.shift!
        shiftDetailVC.isEditingShift = self.isEditingShift
        self.navigationController?.pushViewController(shiftDetailVC, animated: true)
    }
}
