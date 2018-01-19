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

protocol ApplicantListControllerDelegate{
    
    func showApplicantDetail(applicant:JobSeeker)
    //func hire(applicant:JobSeeker ,for:Int )
}
class ApplicantListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var jobID : Int!
    var jobseekerArray = [JobSeeker]()
    var contractSend = false
    var delegate : ApplicantListControllerDelegate!
    
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
        
        //self.delegate?.hire(applicant: js, for: jobID)
        showContractControllertTo(jobseeker: js)
    }
    
    func showDetail(_ sender : UIButton){

        let indexPath = self.tableView.indexPath(of: sender)!
        
        let js = self.jobseekerArray[indexPath.row]
        
        delegate.showApplicantDetail(applicant: js)
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ContractViewController
        dest.shiftID = jobID
        dest.jobseeker = self.selectedJobseeker
    }
    
    func showContractControllertTo(jobseeker : JobSeeker){
        
        let dest = self.storyboard?.instantiateViewController(withIdentifier: "ContractViewController") as! ContractViewController
        dest.shiftID = jobID
        dest.jobseeker = jobseeker
        dest.delegate = self
        present(dest, animated: true, completion: nil)
    }
    
    func filterApplicantList(applicantID:String){
         contractSend = true
        jobseekerArray = jobseekerArray.filter{$0.jobseeker_id == applicantID}
        tableView.reloadData()
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
        
        let js = self.jobseekerArray[indexPath.row]
        if contractSend{
            delegate.showApplicantDetail(applicant: js)
            return
        }
        //self.delegate?.hire(applicant: js, for: jobID)
        showContractControllertTo(jobseeker: js)
    }
}
extension ApplicantListController:ContractSentDelegate{
    
    func contractSentTo(jobseeker: String) {
       
        filterApplicantList(applicantID: jobseeker)
    }

}
