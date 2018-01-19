//
//  CoveredShiftController.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/21/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import PKHUD
class CoveredShiftController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var shifts = [Shift](){
        
        didSet{
            
            setTableView()
        }
    }
    
    let reuseIndentifier = "ShiftsCell"
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: reuseIndentifier, bundle: nil), forCellReuseIdentifier: reuseIndentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getAllCoveredShifts(service: ShiftsService())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTableView()  {
        
        if shifts.count > 0{
            tableView.reloadData()
            tableView.backgroundView = nil
            return
        }
        
        let view = Bundle.main.loadNibNamed("EmptyShiftView", owner: self, options: nil)?.first as? UIView
        let label = view?.viewWithTag(401) as! UILabel
        label.text = "No shift data found"
        self.tableView.backgroundView = view
        
    }
    
    func edit(shift: Shift!) {
        
        let storyboard = UIStoryboard.init(name: "AddShift", bundle: nil)
        
        let addShiftVC : AddShiftController = storyboard.instantiateViewController()
        addShiftVC.shift = shift
        addShiftVC.isEditingShift = true
        self.navigationController?.pushViewController(addShiftVC, animated: true)
        
    }
    
    func viewShiftData(shift:Shift) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewInfoVC : ViewShiftInfoController = storyboard.instantiateViewController()
        viewInfoVC.shift = shift
        
        self.navigationController?.pushViewController(viewInfoVC, animated: true)
    }
    
    func deleteShift(_ sender:UIButton)  {
        
        let index : IndexPath = self.tableView.indexPath(of: sender)!
        let sObj = self.shifts[index.row]
        self.deleteShift(service: ShiftsService(), shift: sObj , cellIndexPath : index , showIndicator: true)
    }
    
    func viewShift(_ sender:UIButton)  {
        let index : IndexPath = self.tableView.indexPath(of: sender)!
        let sObj = self.shifts[index.row]
        self.viewShiftData(shift: sObj)
    }
    
    func editShift(_ sender:UIButton)  {
        let index : IndexPath = self.tableView.indexPath(of: sender)!
        let sObj = self.shifts[index.row]
        self.edit(shift: sObj)
    }
    
}
extension CoveredShiftController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier:self.reuseIndentifier , for: indexPath) as! ShiftsCell
        let shift = self.shifts[indexPath.row]
        
        cell.shiftJobAddress.text = shift.address
        cell.shiftJobTitle.text = shift.role?.uppercased()
        cell.shiftDate.text = shift.convertShiftDate()
        cell.shiftRate.text = "£\(shift.totalCost!)"
        
        cell.progressBar.isHidden = true
        cell.repostButton.isHidden = true
        cell.editLabel.isHidden = true
        
        cell.editButtonWidthConstraint.constant = 0
        
        cell.deleteButton.addTarget(self, action: #selector(deleteShift(_:)), for: .touchUpInside)
        cell.editButton.addTarget(self, action: #selector(editShift(_:)), for: .touchUpInside)
        cell.viewButton.addTarget(self, action: #selector(viewShift(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shifts.count
    }
}

// MARK: - Networking
extension CoveredShiftController{
    
    func getAllCoveredShifts(service:ShiftsService){
        
        service.fetchCovered { (result) in
            switch result {
                
            case .Success(let response):
                if response.success{
                    HUD.flash(.success, delay: 0.0)
                    self.shifts = response.shifts
                }else{
                    HUD.flash(.error, delay: 0.0)
                    
                }
            case .Failure(let error):
                HUD.flash(.error, delay: 0.0)
                self.errorAlert(description: error.localizedDescription)
            }
        }
    }
    
    func deleteShift(service:ShiftsService , shift : Shift , cellIndexPath : IndexPath , showIndicator:Bool)  {
        
        if showIndicator {
            HUD.show(.progress,onView: self.view)
        }
        
        service.deleteShift(id: shift.id!,completionHandler: {result in
            
            HUD.hide()
            switch result{
                
            case .Success(let response):
                print(response)
                
                if response.success{
                    if let index = self.shifts.index(where: { $0.id == shift.id }) {
                        
                        
                        self.shifts.remove(at: index)
                        
                    }
                    
                }else{
                    
                    self.errorAlert(description: response.message)
                }
            case .Failure(let error):
                
                self.errorAlert(description: error.localizedDescription)
                print(error)
            }
        })
    }
}
