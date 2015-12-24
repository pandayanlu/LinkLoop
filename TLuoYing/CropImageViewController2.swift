//
//  CropImageViewController2.swift
//  TLuoYing
//
//  Created by YeWangxing on 11/27/15.
//  Copyright © 2015 YeWangxing. All rights reserved.
//

import UIKit
import AVFoundation

func getShutterSoundPlayer() -> AVAudioPlayer?
{
    let theMainBundle = NSBundle.mainBundle()
    let filename = "Shutter sound"
    let fileType = "mp3"
    let soundfilePath: String? = theMainBundle.pathForResource(filename,
        ofType: fileType,
        inDirectory: nil)
    if soundfilePath == nil
    {
        return nil
    }
    //println("soundfilePath = \(soundfilePath)")
    let fileURL = NSURL.fileURLWithPath(soundfilePath!)
    let result: AVAudioPlayer? = try? AVAudioPlayer(contentsOfURL: fileURL)
    result?.prepareToPlay()
    return result
}

class CropImageViewController2: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    var cropImageView: UIImage?
    var imageView = UIImageView()
    
    
    
    var shutterSoundPlayer = getShutterSoundPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Crop Picture"
        var saveButton : UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveImage:")
        self.navigationItem.rightBarButtonItem = saveButton
        
        scrollView.delegate = self
        
        
        dispatch_async(dispatch_get_main_queue()){
            self.imageView.image = self.cropImageView
            self.imageView.frame = CGRectMake(0, 0, self.cropImageView!.size.width,
                self.cropImageView!.size.height)
            self.imageView.contentMode = UIViewContentMode.Center
            self.imageView.userInteractionEnabled = true
            self.scrollView.addSubview(self.imageView)
            self.scrollView.contentSize = self.cropImageView!.size
            
            let scrollViewFrame = self.scrollView.frame
            let scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width
            let scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height
            
            let minScale = min(scaleHeight, scaleWidth)
            self.scrollView.minimumZoomScale = minScale
            self.scrollView.maximumZoomScale = 1
            self.scrollView.zoomScale = minScale
            
        }
    }
    
    func saveImage(sender : AnyObject){
   
        
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.mainScreen().scale)
        let offset = scrollView.contentOffset
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y)
        scrollView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        delay(0.2) {
        
        self.shutterSoundPlayer?.prepareToPlay()
            
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        let imagePostViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ImagePostViewController") as! ImagePostViewController
        imagePostViewController.croppedImage = image
        self.navigationController?.pushViewController(imagePostViewController, animated: true)
        
        }
        
    }
    
    func centerScrollViewContents(){
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        } else {
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        } else {
            contentsFrame.origin.y = 0
        }
        
        imageView.frame = contentsFrame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func scrollViewDidZoom(scollView: UIScrollView){
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    

    
}
