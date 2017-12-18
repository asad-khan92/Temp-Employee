    //
//  S3TransferManager.swift
//  Temp Provide
//
//  Created by kashif Saeed on 23/05/2017.
//  Copyright © 2017 Attribe. All rights reserved.
//

import Foundation
import AWSS3
import SwiftyUserDefaults
class S3TransferManager{
    
    static let transferManager = AWSS3TransferManager.default()
    static let transferUtility = AWSS3TransferUtility.default()
    
    static var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    static var progressBlock: AWSS3TransferUtilityProgressBlock?
    
    
    class func uploadImage(image : UIImage,to url:String,jobSeekerId:Int, completionHandler:@escaping  (Result<Any>) -> Void){
        
        
        //let str : String =  jobSeekerId
        let uploadKey = "\(jobSeekerId)/\(url)"
        
        
        S3TransferManager.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                //self.progressView.progress = Float(progress.fractionCompleted)
                //self.statusLabel.text = "Uploading..."
            })
        }
        
        S3TransferManager.completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    print("Failed with error: \(error)")
                   // self.statusLabel.text = "Failed"
                    completionHandler(.Failure(error))
                }
//                else if(self.progressView.progress != 1.0) {
//                    //self.statusLabel.text = "Failed"
//                    NSLog("Error: Failed - Likely due to invalid region / filename")
//                }
                else{
                    //self.statusLabel.text = "Success"
                    let s3URL = NSURL(string: "\(Constants.S3Credentials.S3_BUCKET_URL)\(task.key)")!
                    print("\(s3URL)")
                    completionHandler(.Success(s3URL.absoluteString as Any))
                    
                }
            })
        }
        
        S3TransferManager.uploadImage(with: UIImagePNGRepresentation(image)!,key:uploadKey, completionHandler: S3TransferManager.completionHandler )
        
    }
    class func uploadProfilePic(filePath : String,jobSeekerId:String, completionHandler:@escaping  (Result<Any>) -> Void){
        
        let uploadingFileURL = URL(fileURLWithPath: filePath)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket =  Constants.S3Credentials.S3_BUCKET_NAME
        let str : String =  jobSeekerId
        uploadRequest?.key = "\(str)/\(Constants.S3Credentials.profilePic)"
        uploadRequest?.body = uploadingFileURL
        uploadRequest?.contentType = "image/jpeg"
        uploadRequest?.acl = .publicRead
        
        createUploadRequest(request:uploadRequest!, completionHandler: completionHandler)
        
    }
    
    private class func createUploadRequest(request req:AWSS3TransferManagerUploadRequest,completionHandler:@escaping  (Result<Any>) -> Void  ){
        
        S3TransferManager.uploadDataWithRequest(request: req , completionHandler: completionHandler)
    }
    private class func uploadDataWithRequest(request:AWSS3TransferManagerUploadRequest , completionHandler:  @escaping (Result<Any>) -> Void){
        
        
        request.uploadProgress = {(bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                //Update progress
                print("bytesSent = \(bytesSent) , totalBytesSent = \(totalBytesSent) , totalBytesExpectedToSend = \(totalBytesExpectedToSend)")
            })
        }
        
        transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error uploading: \(request.key ?? "") Error: \(error)")
                    }
                } else {
                    print("Error uploading: \(request.key ?? "") Error: \(error)")
                }
                
                
                completionHandler(.Failure(error))
                return nil
            }
            
            //let uploadOutput = task.result
            let s3URL = NSURL(string: "\(Constants.S3Credentials.S3_BUCKET_URL)\(request.key!)")!
            print("\(s3URL)")
            completionHandler(.Success(s3URL.absoluteString as Any))
            return nil
        })
        
    }
    
    class private func uploadImage(with data: Data,key:String,completionHandler : AWSS3TransferUtilityUploadCompletionHandlerBlock?) {
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
       // expression.progressBlock = progressBlock
        
        S3TransferManager.transferUtility.uploadData(
            data,
            bucket: Constants.S3Credentials.S3_BUCKET_NAME,
            key: key,
            contentType: "image/png",
            expression: expression,
            completionHandler: completionHandler).continueWith { (task) -> AnyObject! in
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                   // self.statusLabel.text = "Failed"
                }
                
                if let _ = task.result {
                    //self.statusLabel.text = "Generating Upload File"
                    print("Upload Starting!")
                    // Do something with uploadTask.
                }
                
                return nil;
        }
    }
}
