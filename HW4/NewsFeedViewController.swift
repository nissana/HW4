//
//  NewsFeedViewController.swift
//  Facebook
//
//  Created by Timothy Lee on 8/3/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class NewsFeedViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning  {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedImageView: UIImageView!
    
    var imageView: UIImageView!
    var newImgView: UIImageView! //adding copy

    var selectedImage: UIImage!
    var selectedImageCenter: CGPoint!
    var selectedImageIndex: Int!
    var selectedImageViewPt: CGPoint!
    var selectedImageViewSize: CGSize!
    var newImageRect: CGRect! //adding copy
    
    //Var for Custom View Controller Transitions
    var isPresenting: Bool = true
    var interactiveTransition: UIPercentDrivenInteractiveTransition! //extra interactive effect
    var duration: NSTimeInterval! = 0.5
    var blackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the content size of the scroll view
        scrollView.contentSize = CGSizeMake(view.frame.size.width, feedImageView.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentInset.top = 0
        scrollView.contentInset.bottom = 50
        scrollView.scrollIndicatorInsets.top = 0
        scrollView.scrollIndicatorInsets.bottom = 50
    }
    
    //ON TAP
    @IBAction func tapMainPhoto(sender: UITapGestureRecognizer) {
        
        //record the tapped image (as UIImageView/holder; assign this to prepareForSegue)
        imageView = sender.view as UIImageView
        selectedImage = imageView.image
        selectedImageViewSize = imageView.frame.size
        selectedImageViewPt = CGPointMake(imageView.frame.origin.x, imageView.frame.origin.y)
        selectedImageIndex = whatIndex ()

        println("selectedImage \(selectedImage)")
        println("selectedImageViewSize \(selectedImageViewSize)")
        println("selectedImageViewPt \(selectedImageViewPt)")
        println("selectedImageIndex \(selectedImageIndex)")
        performSegueWithIdentifier("mainPhotoSegue", sender: self)
        println("Perform segues")
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
     //Pass data along with segue
        
        //make a destination as the next screen, the new screen's properties become avail
        var destinationViewController = segue.destinationViewController as PhotoViewController
        
        //pass the tapped/selected image to destination, make sure to have/declare this var in next screen
        destinationViewController.detailImage = selectedImage //pass image
        destinationViewController.detailImageIndex = selectedImageIndex
        
     //Custom presentation transition
        destinationViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        destinationViewController.transitioningDelegate = self
    }
    
    
    //CUSTOM View Controller Transitions
    //1. Prepare for Seque (see above)
    //2. Add delegates on top
    //3. Add func: forPresented, forDissmissed
    func animationControllerForPresentedController(presented: UIViewController!, presentingController presenting: UIViewController!, sourceController source: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        isPresenting = true
        return self
    }
    func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        isPresenting = false
        return self
    }
    //4. Add func to actually controls transitionDuration (with global var, viewDidload assign), animateTransition
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        // Set same value here and in animateTransition below
        return duration
    }

    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        println("animating transition")
        
        var containerView = transitionContext.containerView() //create a main container view
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        if (isPresenting) {
            
            /* Additional I: temp UIImageView, add to window, create a view animation */
            newImageRect = CGRectMake(selectedImageViewPt.x, selectedImageViewPt.y + scrollView.frame.origin.y, selectedImageViewSize.width, selectedImageViewSize.height);
            newImgView = UIImageView(frame: newImageRect)
            newImgView.contentMode = .ScaleAspectFill
            newImgView.clipsToBounds = true
            newImgView.image = selectedImage
           
            containerView.addSubview(newImgView)
            newImgView.alpha = 0 //Twin
            
            /* Additional: create lightbox */
            blackView = UIView(frame: fromViewController.view.frame) //Create UIView(frame: CGRectMake(0, 0, 320, 568))
            blackView.backgroundColor = UIColor.blackColor()
            containerView.addSubview(blackView)
            blackView.alpha = 0 //Lightbox
            
            containerView.addSubview(toViewController.view) //ADD this to/subview to main container view
            toViewController.view.alpha = 0 //TO
            
            UIView.animateWithDuration(1, animations: { () -> Void in //SET visible ALPHA, SIZE
                
                self.blackView.alpha = 1 //Lightbox
                self.newImgView.alpha = 1 //Twin
                
                self.newImgView.center = CGPoint(x: 160.0, y: 284.0)
                self.newImgView.frame = CGRect(x: 0, y: 44, width: 320, height: 480)
                
                delay(0.5, { () -> () in
                    UIView.animateWithDuration(0.7, animations: { () -> Void in
                        toViewController.view.alpha = 1 //TO
                    })
                })

                }) { (finished: Bool) -> Void in
                    transitionContext.completeTransition(true) //mark trans as done
            }
        }
        //Dismissing
        else {
            
            fromViewController.view.alpha = 1 //FROM
            UIView.animateWithDuration(1, animations: { () -> Void in //SET invisible ALPHA, SIZE, once done: remove from main
                fromViewController.view.alpha = 0 //FROM

                self.newImgView.alpha = 0 //invisible
                self.blackView.alpha = 0 /* Additional: light box opacity to invisible*/
                
                self.newImgView.center = CGPoint(x: self.selectedImageViewPt.x, y: self.selectedImageViewPt.y)
                self.newImgView.frame = self.newImageRect
                
                }) { (finished: Bool) -> Void in
                    transitionContext.completeTransition(true) //mark trans as done
                    fromViewController.view.removeFromSuperview() //REMOVE 2nd/from view from super/main container view
                    
                    self.newImgView.removeFromSuperview()
                    self.blackView.removeFromSuperview() /* Additional: remove light box*/
            }
        }
    }
    
    func whatIndex () -> Int {
        var index = 0
        
        if selectedImageViewPt == CGPoint(x: 3,y: 82) {
            index = 0
        }
        else if selectedImageViewPt == CGPoint(x: 3,y: 240) {
            index = 1
        }
        else if selectedImageViewPt == CGPoint(x: 161,y: 82) {
            index = 2
        }
        else if selectedImageViewPt == CGPoint(x: 161,y: 187) {
            index = 3
        }
        else if selectedImageViewPt == CGPoint(x: 161,y: 293) {
            index = 4
        }
        return index
    }
  
    
}
