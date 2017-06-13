//
//  ShiftsViewController.swift
//  TempEmployee
//
//  Created by kashif Saeed on 31/05/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import PKHUD
import QuartzCore
import Intercom

class ShiftsViewController: UIViewController {

    var footerView: FooterView?
    var footerViewFrame: CGRect?
    var footerNeedsLayout : Bool! = true
    var indexPathToBeDeleted : IndexPath? // sets when user deletes any shift
   
    
    @IBOutlet weak var tableView: UITableView!
    
    var shiftsData  = [Shift](){
        
        didSet{
            self.footerNeedsLayout = true
            
            if self.indexPathToBeDeleted != nil{
                self.tableView.deleteRows(at: [indexPathToBeDeleted!], with: .automatic)
                self.indexPathToBeDeleted = nil
            }else{
                
                    self.tableView.reloadData()
    
                    self.refreshControl.endRefreshing()
                    self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSForegroundColorAttributeName:UIColor.ShiftHeaderFontColor(),NSFontAttributeName:UIFont(name:"Lato-Light", size: 20)!])
                   
            }
        }
    }
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSForegroundColorAttributeName:UIColor.ShiftHeaderFontColor(),NSFontAttributeName:UIFont(name:"Lato-Light", size: 20)!])
        return refreshControl
    }()
    
    let reuseIndentifier = "ShiftsCell"
   
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: reuseIndentifier, bundle: nil), forCellReuseIdentifier: reuseIndentifier)
        
        footerView = Bundle.main.loadNibNamed("FooterView", owner: self, options: nil)?.first as! FooterView?
        
        footerView?.newShiftButton.addTarget(self, action: #selector(addNewShift),for: .touchUpInside)
        
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as! UIView?
        
        self.fetchShifts(service:ShiftsService(),showIndicator: true)
        
        self.tableView.tableHeaderView = headerView
        
        self.tableView.refreshControl = refreshControl
        
        self.navigationController?.navigationBar.isHidden = true
        
         Intercom.setLauncherVisible(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        if self.footerNeedsLayout! {
            footerView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
             self.footerViewFrame = self.footerView?.frame
            self.setupFooter()
        }
    }
    
    func setupFooter() {
        self.tableView.tableFooterView = nil;
        self.footerView?.frame = self.frameForFooter();
        self.tableView.tableFooterView = self.footerView;
        self.footerNeedsLayout = false;
    }
    func frameForFooter() -> CGRect {
        
            var frame = self.footerView?.frame;
            let visibleSpace : CGFloat = self.tableView.frame.height - self.tableView.contentInset.bottom - self.tableView.contentInset.top;
            if (self.tableView.contentSize.height < visibleSpace - (frame?.height)!) {
                let emptySpace : CGFloat = visibleSpace - self.tableView.contentSize.height;
                frame?.size.height = emptySpace;
            }
            else {
                frame = self.footerViewFrame!;
            }
            
            return frame!;
    }

    func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        self.fetchShifts(service: ShiftsService(),showIndicator: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.fetchShifts(service: ShiftsService(), showIndicator: false)
    }
}
extension ShiftsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shiftsData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier:self.reuseIndentifier , for: indexPath) as! ShiftsCell
        let shift = self.shiftsData[indexPath.row]
        cell.shiftJobAddress.text = shift.address
        cell.shiftJobTitle.text = shift.role?.uppercased()
        cell.shiftDate.text = shift.shift_date
        cell.shiftRate.text = "£\(shift.price_per_hour!)"
        
        cell.deleteButton.addTarget(self, action: #selector(deleteShift(_:)), for: .touchUpInside)
        cell.editButton.addTarget(self, action: #selector(editShift(_:)), for: .touchUpInside)
        cell.viewButton.addTarget(self, action: #selector(viewShift(_:)), for: .touchUpInside)
        
        cell.progressBar.setProgress(self.returnProgress(value: indexPath.row), animated: true)
        
        switch shift.assign_status!{
            
        case .pending:
            
             let minStr = "MINS"
             let str = NSMutableAttributedString(string: "\(minStr) UNTILL COVERED")
             
             str.addAttributes([NSFontAttributeName:UIFont(name:"Lato-Light", size: 10)!], range: NSMakeRange(0, minStr.characters.count))
             str.addAttributes([NSFontAttributeName:UIFont(name:"Lato-Bold", size: 10)!], range: NSMakeRange(minStr.characters.count, str.length - minStr.characters.count))
             
               cell.shiftStatus.attributedText = str
                cell.progressBar.isHidden = false
                cell.attachTimer() // also set shiftPostedDate 
        case .covered:
            
            let shiftStr = "SHIFT"
            let str = NSMutableAttributedString(string: "\(shiftStr) COVERED")
            
            str.addAttributes([NSFontAttributeName:UIFont(name:"Lato-Light", size: 10)!], range: NSMakeRange(0, shiftStr.characters.count))
            str.addAttributes([NSFontAttributeName:UIFont(name:"Lato-Bold", size: 10)!], range: NSMakeRange(shiftStr.characters.count, str.length - shiftStr.characters.count))
            
             cell.shiftStatus.attributedText = str
             cell.progressBar.isHidden = true
        case .completed:
            print("")
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let nCell = cell as! ShiftsCell
        let shift = self.shiftsData[indexPath.row]
        
        if shift.assign_status == ShiftStatus.completed {
            
            nCell.completedView.isHidden = false
        }else{
            
            nCell.completedView.isHidden = true
        }
        nCell.alpha = 0
        nCell.contentView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        footerView?.alpha = 0
        footerView?.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: .calculationModeLinear, animations: {
            // each keyframe needs to be added here
            // within each keyframe the relativeStartTime and relativeDuration need to be values between 0.0 and 1.0
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.8, animations: {
                
                nCell.alpha = 1
                nCell.contentView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.footerView?.alpha = 1
                self.footerView?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2, animations: {
                
                nCell.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.footerView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                
            })
  
        }, completion: {finished in
            // any code entered here will be applied
            // once the animation has completed
           
        })
   
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sObj = self.shiftsData[indexPath.row]
        self.viewShiftData(shift: sObj)
        
    }
    
    func returnProgress(value:Int)-> CGFloat{
        
       return CGFloat(value)/100.0 + 0.1
    }
   
    func deleteShift(_ sender:UIButton)  {
        
        let index : IndexPath = self.tableView.indexPath(of: sender)!
        let sObj = self.shiftsData[index.row]
        self.deleteShift(service: ShiftsService(), shift: sObj , cellIndexPath : index , showIndicator: true)
    }
    
    func viewShift(_ sender:UIButton)  {
        let index : IndexPath = self.tableView.indexPath(of: sender)!
        let sObj = self.shiftsData[index.row]
        self.viewShiftData(shift: sObj)
    }
    
    func editShift(_ sender:UIButton)  {
        let index : IndexPath = self.tableView.indexPath(of: sender)!
        let sObj = self.shiftsData[index.row]
        self.edit(shift: sObj)
    }
    
    func viewShiftData(shift:Shift) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewInfoVC : ViewShiftInfoController = storyboard.instantiateViewController()
        viewInfoVC.shift = shift
        self.navigationController?.pushViewController(viewInfoVC, animated: true)
    }
}

extension ShiftsViewController{
    
    func fetchShifts(service:ShiftsService , showIndicator:Bool)  {
        
        if showIndicator {
             HUD.show(.progress,onView: self.view)
        }
       
       if self.refreshControl.isRefreshing {
            
            self.refreshControl.attributedTitle = NSAttributedString(string: "Loading...", attributes: [NSForegroundColorAttributeName:UIColor.ShiftHeaderFontColor(),NSFontAttributeName:UIFont(name:"Lato-Light", size: 20)!])
        }
        service.fetchMyShifts(with: {result in
            
            switch result{
                
            case .Success(let response):
                print(response)
                HUD.hide()
                if response.success{
                    self.shiftsData = response.shifts
                }else{
                    HUD.hide()
                   
                    self.errorAlert(description: response.message)
                }
            case .Failure(let error):
                //HUD.flash(.error, delay: 0.0)
                self.errorAlert(description: error.localizedDescription)
                print(error)
            }
        })
    }
    
    func deleteShift(service:ShiftsService , shift : Shift , cellIndexPath : IndexPath , showIndicator:Bool)  {
        
        if showIndicator {
            HUD.show(.progress,onView: self.view)
        }
        
        if self.refreshControl.isRefreshing {
            
            self.refreshControl.attributedTitle = NSAttributedString(string: "Loading...", attributes: [NSForegroundColorAttributeName:UIColor.ShiftHeaderFontColor(),NSFontAttributeName:UIFont(name:"Lato-Light", size: 20)!])
        }
        service.deleteShift(id: shift.id!,completionHandler: {result in
            
            switch result{
                
            case .Success(let response):
                print(response)
                HUD.hide()
                if response.success{
                   if let index = self.shiftsData.index(where: { $0.id == shift.id }) {
                    
                    
                        self.shiftsData.remove(at: index)
                    
                    }
                   
                }else{
                    HUD.hide()
                    self.errorAlert(description: response.message)
                }
            case .Failure(let error):
                HUD.hide()
                self.errorAlert(description: error.localizedDescription)
                print(error)
            }
        })
    }
    func addNewShift(sender: UIButton!) {
        
        let storyboard = UIStoryboard.init(name: "AddShift", bundle: nil)
        let addShiftVC : AddShiftController = storyboard.instantiateViewController()
        self.navigationController?.pushViewController(addShiftVC, animated: true)
        
    }
    func edit(shift: Shift!) {
        
        let storyboard = UIStoryboard.init(name: "AddShift", bundle: nil)
        
        let addShiftVC : AddShiftController = storyboard.instantiateViewController()
        addShiftVC.shift = shift
        addShiftVC.isEditingShift = true
        self.navigationController?.pushViewController(addShiftVC, animated: true)
        
    }
    
}
