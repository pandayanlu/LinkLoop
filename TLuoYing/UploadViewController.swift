//
//  UploadViewController.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/13/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit
import MobileCoreServices
import SwiftHTTP

class UploadViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    var newMedia: Bool?
    var localPath : String = ""
    let defaultsUserData = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if (mediaType == (kUTTypeImage as String)) {
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
            self.imageView.image = image
            
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(image, self,
                    "image:didFinishSavingWithError:contextInfo:", nil)
            } else {
                let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
                //let imageName = imageURL.lastPathComponent
                //let documentDirectory : String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
                
                localPath = imageURL.path!
                print("localPath = \(localPath)")
            }
            
            let cropImageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CropImageViewController2") as! CropImageViewController2
            cropImageViewController.cropImageView = image
            self.navigationController?.pushViewController(cropImageViewController, animated: true)
            
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true,
                completion: nil)
        } else {
            
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func useCamera(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: true,
                    completion: nil)
                newMedia = true
        }
    }
    
    @IBAction func useCameraRoll(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.PhotoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true,
                    completion: nil)
                newMedia = false
        }
    }
    
    func displayAlertMessage(message: String){
        let alert = UIAlertController(
            title: "Alert", message: message
            , preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func createRequest (email: String, uuid: String, api_key: String, title: String, style: String) -> NSURLRequest {
        
        let param = [
            "email" : email,
            "uuid" : uuid,
            "title" : title,
            "style" : style
        ]
        
        let boundary = generateBoundaryString()
        
        let url = NSURL(string: uploadURL + "/" + api_key + "/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "postFileImage", paths: [self.localPath], boundary: boundary)
        
        return request
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, paths: [String]?, boundary: String) -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 1)
        
        if paths != nil {
            for _ in paths! {
                let filename = "upload.jpg"
                let mimetype = "image/jpg"
                
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
                body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                body.appendData(imageData!)
                body.appendString("\r\n")
            }
        }
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    //    func mimeTypeForPath(path: String) -> String {
    //        let pathExtension = path.pathExtension
    //
    //        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
    //            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
    //                return mimetype as String
    //            }
    //        }
    //        return "application/octet-stream";
    //    }
    
}
