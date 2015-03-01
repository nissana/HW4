//
//  PhotoViewController.swift
//  HW4
//
//  Created by Nissana Akranavaseri on 2/26/15.
//  Copyright (c) 2015 NA. All rights reserved.
//

import UIKit

//NEED to create seque back to original screen? or copy everything prep segue

class PhotoViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var photoAction: UIImageView!
    @IBOutlet weak var doneButton: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var interactiveTransition: UIPercentDrivenInteractiveTransition!
    var detailImage: UIImage! //passed from segue
    var detailImageIndex: Int!
    var duration: NSTimeInterval! = 0.5
    var accessibilityIdentifier: String!
    
    var imageArray: [UIImage]!
    
    @IBOutlet weak var ImageView1: UIImageView!
    //for scrollView pan
    var originalCenter: CGPoint!
    var startingCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = detailImage  // = UIImage(named: "")
        println("imageView.image \(imageView.image)")
        
        imageArray = [
            UIImage(named: "wedding1.png")!,
            UIImage(named: "wedding2.png")!,
            UIImage(named: "wedding3.png")!,
            UIImage(named: "wedding4.png")!,
            UIImage(named: "wedding5.png")!
        ]
        
        scrollView.contentSize = CGSizeMake(1920, 1024) //524 is image height + photo action height
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        var page = Int(scrollView.contentOffset.x / 320)
//        println("SCROLL \(scrollView.contentOffset.x)")
//
//    }
    
    /*
    // MARK: - Navigation
    */
    
    @IBAction func tapDone(sender: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
        //downward, fade
    }
    @IBAction func panDetailPhoto(sender: UIPanGestureRecognizer) {
        
        var location = sender.locationInView(view)
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
        if (sender.state == UIGestureRecognizerState.Began){
            originalCenter = scrollView.center
            self.imageView.alpha = 1
            
        } else if (sender.state == UIGestureRecognizerState.Changed){
            println("location \(location)")
            println("translation \(translation)")
            println("velocity \(velocity)")
            
            //scroll vertically
            if (translation.x > -20 && translation.x < 20) {
                println("VERTICALLY")
                scrollView.center = CGPoint(x: originalCenter.x, y: originalCenter.y + translation.y)
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    self.doneButton.alpha = 0
                    self.scrollView.alpha = 0.8
                    self.photoAction.alpha = 0
                    self.scrollView.backgroundColor = UIColor(white: 0, alpha: 1)
                })
                
            }
            //scroll horizontally
            else {
                resetScrollView ()
                if (velocity.x > 0) {
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        //self.imageView.center.x = self.imageView.center.x + 80 //.75 of screen
                        //self.ImageView1.center.x = self.imageView.center.x - 320 - 10
                        self.imageView.center.x = -80
                        self.ImageView1.center.x = 250
                    })
                } else{
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        //self.imageView.center.x = self.imageView.center.x - 80 // .75 of screen
                        //self.ImageView1.center.x = self.imageView.center.x + 320 + 10
                        self.imageView.center.x = 80
                        self.ImageView1.center.x = 410
                    })
                }
            }
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            //scroll vertically
            if (translation.x > -20 && translation.x < 20) {
                if translation.y > 100.0 || translation.y < -100.0{
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        self.scrollView.alpha = 0
                    })
                    dismissViewControllerAnimated(true, completion: nil)
                }
                else{ //back to normal
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        self.resetScrollView ()
                    })
                    scrollView.center = CGPoint(x: originalCenter.x, y: originalCenter.y)
            }}
                
            //scroll horizontally
            else {
                //next page
                resetScrollView ()
                
                if (velocity.x > 0) {
                    if detailImageIndex == 4 { //exception
                        UIView.animateWithDuration(self.duration, animations: { () -> Void in
                            self.imageView.image = self.imageArray[0]
                            self.detailImageIndex = 0 //reset
                            self.imageView.alpha = 1
                        })
                    }
                    else {
                        self.detailImageIndex = self.detailImageIndex + 1
                        UIView.animateWithDuration(self.duration, animations: { () -> Void in
                            self.imageView.image = self.imageArray[self.detailImageIndex]
                            self.imageView.alpha = 1
                            self.imageView.center.x = -160+320
                            self.ImageView1.center.x = 160+320
                        })
                    }
                }
                //previous page
                else {
                    if detailImageIndex == 0 { //exception
                        UIView.animateWithDuration(self.duration, animations: { () -> Void in
                            self.imageView.image = self.imageArray[self.imageArray.count - 1] //last one
                            self.detailImageIndex = self.imageArray.count - 1
                            self.imageView.alpha = 1
                        })
                    }
                    else{
                        self.detailImageIndex = self.detailImageIndex - 1
                        UIView.animateWithDuration(self.duration, animations: { () -> Void in
                            //self.imageView.image = self.imageArray[self.detailImageIndex]
                            self.imageView.alpha = 1
                            self.imageView.center.x = -160
                            self.ImageView1.center.x = 160
                        })
                    }
                }//previous page
              }//horizontally
            }
    }//end Pan
    
    
    func resetScrollView (){
        doneButton.alpha = 1
        scrollView.alpha = 1
        photoAction.alpha = 1
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.center = CGPoint(x: originalCenter.x, y: originalCenter.y)
    }
    
    
    //PINCH to ZOOM picture
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return imageView
    }
    
    @IBAction func pinchImageToZoom(sender: UIPinchGestureRecognizer) {
        
        var scale = sender.scale
        var velocity = sender.velocity
        
        if (sender.state == UIGestureRecognizerState.Began){
            //var zoomIn = viewForZoomingInScrollView(scrollView)
            
        } else if (sender.state == UIGestureRecognizerState.Changed){
            viewForZoomingInScrollView(scrollView)
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.imageView.transform = CGAffineTransformMakeScale(scale, scale)
            })
        } else if (sender.state == UIGestureRecognizerState.Ended){
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.imageView.transform = CGAffineTransformMakeScale(1, 1)
            })
        }
        
        
    }
}
