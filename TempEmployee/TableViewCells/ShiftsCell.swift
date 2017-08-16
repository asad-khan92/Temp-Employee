 //
//  ShiftsCell.swift
//  TempEmployee
//
//  Created by kashif Saeed on 31/05/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import UIKit
import CircleProgressBar
import AFDateHelper
import SDWebImage
 
class ShiftsCell: UITableViewCell {
    
    //@IBOutlet weak var shiftCompletedLabel: UILabel!
    @IBOutlet weak var progressBar: CircleProgressBar!
    //@IBOutlet weak var completedView: UIView!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var hideMoreButton: UIButton!
    @IBOutlet weak var cellBoxheightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellBoxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var moreOptionsView: UIView!
    @IBOutlet weak var shiftApplicantImage: UIImageView!
    @IBOutlet weak var shiftStatus: UILabel!
    @IBOutlet weak var shiftRate: UILabel!
    @IBOutlet weak var shiftJobAddress: UILabel!
    @IBOutlet weak var shiftJobTitle: UILabel!
    @IBOutlet weak var shiftDate: UILabel!
    @IBOutlet weak var repostButton: UIButton!
   
    @IBOutlet weak var blueTickMark: UIImageView!
    var progressTimer : Timer?
    var shiftPostedDate = 0.0
    
    var countDown = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.progressTimer = nil
        self.hideOptionsView()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func hideOptionsView(){
        
        self.cellBoxWidthConstraint.constant = 0
        self.cellBoxheightConstraint.constant = 0
        
        self.hideMoreButton.alpha = 0
        
        self.viewButton.alpha = 0
        self.viewLabel.alpha = 0
        
        self.editButton.alpha = 0
        self.editLabel.alpha = 0
        
        self.deleteButton.alpha = 0
        self.deleteLabel.alpha = 0
        
        self.moreOptionsView.isUserInteractionEnabled = false
        
    }
    @IBAction func hideMoreOptions(_ sender: Any) {
        self.hideOptionsView()
    }
    @IBAction func showMoreOptions(_ sender: Any) {
        
        
        let duration = 1.0
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.calculationModeLinear
        
        self.editButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.deleteButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.viewButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
         self.layoutIfNeeded()
        
        UIView.animateKeyframes(withDuration: duration, delay: delay, options: options, animations: {
            // each keyframe needs to be added here
            // within each keyframe the relativeStartTime and relativeDuration need to be values between 0.0 and 1.0
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4, animations: {
                // start at 0.00s (5s × 0)
                // duration 1.67s (5s × 1/3)
                // end at   1.67s (0.00s + 1.67s)
                self.cellBoxWidthConstraint.constant = self.moreOptionsView.frame.width
                self.cellBoxheightConstraint.constant = self.moreOptionsView.frame.height
                self.viewButton.alpha = 1
                self.viewButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.hideMoreButton.alpha = 1
                self.viewLabel.alpha = 1
                 self.layoutIfNeeded()
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3, animations: {
                
                self.editButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.editButton.alpha = 1
                self.editLabel.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3, animations: {
                
                self.deleteButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.deleteButton.alpha = 1
                self.deleteLabel.alpha = 1
            })
    
            
            
        }, completion: {finished in
            // any code entered here will be applied
            // once the animation has completed
            self.moreOptionsView.isUserInteractionEnabled = true
        })
    }
    
    func attachTimerIfNeed(shift:Shift)  {
        
        guard  let component =  shift.isPostedWithinAnHour() else{
            
            return
        }
        
        
        if (component.hour)! <= 1 {
            
            let minStr = "MINS"
            let str = NSMutableAttributedString(string: "\(minStr) UNTILL COVERED")
            
            str.addAttributes([NSFontAttributeName:UIFont(name:"Lato-Light", size: 10)!], range: NSMakeRange(0, minStr.characters.count))
            str.addAttributes([NSFontAttributeName:UIFont(name:"Lato-Bold", size: 10)!], range: NSMakeRange(minStr.characters.count, str.length - minStr.characters.count))
            
            self.shiftStatus.attributedText = str
            self.shiftStatus.isHidden = false
            self.progressBar.isHidden = false
            self.repostButton.isHidden = true
            self.shiftApplicantImage.isHidden = true
            self.countDown = 60 - component.minute! // difference in minutes
            self.updateTimer() // call once before timer starts updating value
            self.attachTimer() // also set shiftPostedDate
            //self.completedView.isHidden = true
            self.blueTickMark.isHidden = true
        }else{
            
            self.progressBar.isHidden = true
            self.progressTimer = nil
            self.shiftStatus.isHidden = true
            self.repostButton.isHidden = false
            self.shiftStatus.isHidden = true
            self.shiftApplicantImage.isHidden = true
            //self.completedView.isHidden = true
            self.blueTickMark.isHidden = true
        }

    }
    
    func attachTimer()  {
        
        self.progressTimer = Timer()
        self.progressTimer  = Timer.scheduledTimer(timeInterval: 60, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        
    }
    func updateTimer()   {
        // check if value is 60 mins
        // if tru invalidate timer and hide progres bar
        if self.countDown == 0{
            self.progressTimer?.invalidate()
            self.progressBar.isHidden = true
            self.repostButton.isHidden = false
            //self.completedView.isHidden = true
            return
        }
        self.countDown -= 1
        let  progressInDecimal = fabs(0.6 - (CGFloat(self.countDown)/100))
        self.progressBar.setProgress(progressInDecimal, animated: true)
        
        self.progressBar.setHintTextGenerationBlock { (progress) -> String? in

            return "\(self.countDown)"
        }
    }
    
}

