//
//  ViewController.swift
//  Flicker Finder
//
//  Created by Daniele Vitali on 16/11/15.
//  Copyright © 2015 Daniele Vitali. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    let BASE_URL = "https://api.flickr.com/services/rest/"
    
    @IBOutlet weak var imgFlicker: UIImageView!
    @IBOutlet weak var tfTextSearch: UITextField!
    @IBOutlet weak var tfLatitude: UITextField!
    @IBOutlet weak var tfLongitude: UITextField!
    @IBOutlet weak var lblImageTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var tapRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfTextSearch.delegate = self
        tfLatitude.delegate = self
        tfLongitude.delegate = self
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapRecognizer.numberOfTapsRequired = 1
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil);
        
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeGestureRecognizer(tapRecognizer)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if scrollView.contentOffset.y == 0 {
            let info = notification.userInfo!
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
            let insets = UIEdgeInsetsMake(scrollView.contentInset.top, 0, keyboardSize.height, 0)
        
            scrollView.contentInset = insets
            scrollView.scrollIndicatorInsets = insets
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + keyboardSize.height)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if scrollView.contentOffset.y > 0 {
            let info = notification.userInfo!
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
            let insets = UIEdgeInsetsMake(scrollView.contentInset.top, 0, keyboardSize.height, 0)
        
            scrollView.contentInset = insets
            scrollView.scrollIndicatorInsets = insets
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - keyboardSize.height)
        }
    }
    
    @IBAction func searchDescription(sender: AnyObject) {
        if let text = tfTextSearch.text {
            if text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                lblImageTitle.text = "Type a text first!"
                return
            }
            
            view.endEditing(true)
            
            var methodParams = Utils.buildDefaultRequestParameters()
            methodParams["text"] = text
            sendRequest(BASE_URL + Utils.escapedParameters(methodParams))
        }
    }
    
    @IBAction func serachCoordinates(sender: AnyObject) {
        if var latitudeString = tfLatitude.text, longitudeString = tfLongitude.text {
            
            latitudeString = latitudeString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            longitudeString = longitudeString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if latitudeString == "" || longitudeString == ""{
                lblImageTitle.text = "Type a latitude and longitude first!"
                return
            }
            
            if let latitude = Double(latitudeString), longitude = Double(longitudeString) where latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180 {
                view.endEditing(true)
                var methodParams = Utils.buildDefaultRequestParameters()
                methodParams["bbox"] = Utils.createBoundingBoxString(latitude: latitude, longitude: longitude)
                sendRequest(BASE_URL + Utils.escapedParameters(methodParams))
            } else {
                lblImageTitle.text = "Latitude and longitude must be numeric between [-90, 90] and [-180, 180]"
            }
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    private func sendRequest(url: String) {
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: NSURL(string: url)!)
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error == nil && data != nil {
                let image = Utils.parsePhotosJsonAndPickAnImage(data!)
                dispatch_async(dispatch_get_main_queue(), {
                    self.setImage(image)
                })
            }
        })
        task.resume()
    }
    
    private func setImage(image: Image?) {
        if let image = image {
            self.imgFlicker.image = UIImage(data: NSData(contentsOfURL: NSURL(string: image.url)!)!)
            self.lblImageTitle.text = image.title
        } else {
            self.imgFlicker.image = nil
            self.lblImageTitle.text = "No photos found"
        }

    }
}

