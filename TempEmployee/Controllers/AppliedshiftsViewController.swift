//
//  AppliedshiftsViewController.swift
//  Temp Provide
//
//  Created by Apple on 25/07/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import Intercom
class AppliedshiftsViewController: UIViewController {

    
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet var dotButtons: [UIButton]!
    var viewControllers: [UIViewController]!
    
    var selectedIndex: Int = 0
    
  //  @IBOutlet var screenEdgePanGesture: UIScreenEdgePanGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.addGestureRecognizer(screenEdgePanGesture)
        view.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isHidden = true
        
        let storyboard = UIStoryboard.storyboard(.main)
        
        
        let coveredVC : CoveredShiftController = storyboard.instantiateViewController()
        
            
            
            let completedVC : CompletedShiftController = storyboard.instantiateViewController()
            
            let postedVC : PostedShiftController = storyboard.instantiateViewController()
            
            
            
            viewControllers = [coveredVC,postedVC,completedVC]
            
       
        
        tabButtons[selectedIndex].isSelected = true
        tabSelected(tabButtons[selectedIndex])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.fetchShifts(service: ShiftsService(), showIndicator: false)
        
        Intercom.setLauncherVisible(true)
        Intercom.setBottomPadding(32)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Intercom.setLauncherVisible(false)
    }
    
    @IBAction func tabSelected(_ sender: UIButton) {
        
        self.animateButton(button:sender)
        let previousIndex = selectedIndex
        selectedIndex = self.tabButtons.index(of: sender)!
        tabButtons[previousIndex].isSelected = false
        dotButtons[previousIndex].backgroundColor = UIColor.clear
        dotButtons[selectedIndex].backgroundColor = UIColor.blueThemeColor()
        
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        sender.isSelected = true
        let vc = viewControllers[selectedIndex]
        addChildViewController(vc) // Calls the viewWillAppear method of the ViewController you are adding
        vc.view.frame = self.container.bounds
        container.addSubview(vc.view)
        
        vc.didMove(toParentViewController: self) // Call the viewDidAppear method of the ViewController you are adding
    }
    
    func animateButton(button:UIButton){
        //self.tabButtons.map{ if $0 != button{ $0.isHidden = true}}
        //button.transform = CGAffineTransform.init(translationX: self.tabButtons[1].center.x, y: self.tabButtons[1].center.y)
        
    }
   
    @IBAction func postANewJob(_ sender: Any) {
    }
    
}
