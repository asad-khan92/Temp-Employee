//
//  CompletedShiftController.swift
//  TempEmployee
//
//  Created by Asad Khan on 11/21/17.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import PKHUD
class CompletedShiftController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var shifts = [Shift](){
        
        didSet{
            
            setTableView()
        }
    }
    
    let reuseIndentifier = "ShiftsCell"
    override func loadView() {
        super.loadView()
        print("loadView called")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad called")
        self.tableView.register(UINib(nibName: reuseIndentifier, bundle: nil), forCellReuseIdentifier: reuseIndentifier)
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getAllCompletedShifts(service: ShiftsService())
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

}
extension CompletedShiftController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shifts.count
    }
}

// MARK: - Networking
extension CompletedShiftController{
    
    func getAllCompletedShifts(service:ShiftsService){
        
        service.fetchCompleted { (result) in
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
}
