//
//  ApplicantListController.swift
//  TempEmployee
//
//  Created by Asad Khan on 12/12/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import SDWebImage
import Spring

class ApplicantListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var jobID : Int!
    var jobseekerArray = [JobSeeker]()
    var contractSend = false
    
    fileprivate var selectedJobseeker : JobSeeker!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hire(_ sender:UIButton){
        
        let indexPath = self.tableView.indexPath(of: sender)!
        
        let js = self.jobseekerArray[indexPath.row]
        
        self.selectedJobseeker = js
        
        
        let dest = self.storyboard?.instantiateViewController(withIdentifier: "ContractViewController") as! ContractViewController
        dest.shiftID = jobID
        dest.jobseeker = self.selectedJobseeker
        
        present(dest, animated: true, completion: nil)
        //performSegue(withIdentifier: "segueToContract", sender: self)
    }
    
    func showDetail(_ sender : UIButton){

        let indexPath = self.tableView.indexPath(of: sender)!
        
        let js = self.jobseekerArray[indexPath.row]
    }
    
    func animateDetailView(with js : JobSeeker){
        
        let applicantDetail = Bundle.main.loadNibNamed("ApplicantDetail", owner: self, options: nil)?.first as! ApplicantDetail?
        
        applicantDetail?.applicantName.text = js.username
        applicantDetail?.applicantImageView.sd_setImage(with:URL.init(string:js.image_path!))
        applicantDetail?.set(rating:js.average_rating!)
        applicantDetail?.set(licenses: js.jobseeker_licenses)
        
        
        view.addSubview(applicantDetail!)
        //applicantDetail?.applicantDistance.text = js.distance
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ContractViewController
        dest.shiftID = jobID
        dest.jobseeker = self.selectedJobseeker
    }
}
extension ApplicantListController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobseekerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplicantCell", for: indexPath) as! ApplicantCell
        let js = jobseekerArray[indexPath.row]
        
        if contractSend{
            
            cell.hireButton.isHidden = true
        }
        cell.name.text  = js.username
        cell.address.text = js.address1
        cell.imgView?.sd_setImage(with: URL.init(string: js.image_path!))
        
        cell.hireButton.addTarget(self, action: #selector(hire(_:)), for: .touchUpInside)
        cell.detailButton.addTarget(self, action: #selector(showDetail(_:)), for: .touchUpInside)
        if let rating = js.average_rating
        {

            for (index,button) in cell.rating.enumerated()
                
            {
                
                if index == rating{
                    
                    break
                    
                }
                
                button.isSelected = true
                
            }
            
            
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedJobseeker = self.jobseekerArray[indexPath.row]
        
        performSegue(withIdentifier: "segueToContract", sender: self)
    }
}
extension ApplicantListController{
    
//    func sendContract(to jobseeker:JobSeeker , service : ShiftsService){
//
//        contractSend = true
//
//        jobseekerArray = jobseekerArray.filter{$0.jobseeker_id == jobseeker.jobseeker_id}
//        tableView.reloadData()
//
//        service.send(jobID: jobID , contract_to: jobseeker) { (response) in
//
//            switch response{
//
//            case .Success(let result):
//                print(result)
//
//            case .Failure(let error):
//                print(error)
//            }
//        }
//    }
}
