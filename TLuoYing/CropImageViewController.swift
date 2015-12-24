//
//  CropImageViewController.swift
//  TLuoYing
//
//  Created by YeWangxing on 9/19/15.
//  Copyright (c) 2015 YeWangxing. All rights reserved.
//

import UIKit
import AVFoundation

func loadShutterSoundPlayer() -> AVAudioPlayer?
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

class CropImageViewController: UIViewController , CroppableImageViewDelegateProtocol{

    @IBOutlet weak var saveButton: UIButton!
    var cropImageView: UIImage?
    var shutterSoundPlayer = loadShutterSoundPlayer()
    
    @IBOutlet weak var cropView: CroppableImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Crop Picture"
        var saveButton : UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveImage:")
        self.navigationItem.rightBarButtonItem = saveButton
        
                dispatch_async(dispatch_get_main_queue()){
                    self.cropView.imageToCrop = self.cropImageView
                }

   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func saveImage(sender : AnyObject){
        
        if let croppedImage = cropView.croppedImage(){
            delay(0)
                {
                    self.shutterSoundPlayer?.play()
                    UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil);
                    
                    delay(0.2)
                        {
                            self.shutterSoundPlayer?.prepareToPlay()
                            
                            let imagePostViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ImagePostViewController") as! ImagePostViewController
                            imagePostViewController.croppedImage = croppedImage
                            self.navigationController?.pushViewController(imagePostViewController, animated: true)
                            
                    }
            }
        }
        
    }
    
    func haveValidCropRect(haveValidCropRect:Bool){
        self.saveButton.enabled = haveValidCropRect
    }
}
