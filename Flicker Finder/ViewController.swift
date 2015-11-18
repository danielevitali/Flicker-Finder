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
        let info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        let insets = UIEdgeInsetsMake(scrollView.contentInset.top, 0, keyboardSize.height, 0)
        
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + keyboardSize.height)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        let insets = UIEdgeInsetsMake(scrollView.contentInset.top, 0, keyboardSize.height, 0)
        
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - keyboardSize.height)
    }
    
    @IBAction func searchDescription(sender: AnyObject) {
        if let text = tfTextSearch.text {
            if text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                tfTextSearch.text = "Type a text first!"
                return
            }
            
            view.endEditing(true)
            
            var methodParams = Utils.buildDefaultRequestParameters()
            methodParams["text"] = text
            sendRequest(BASE_URL + Utils.escapedParameters(methodParams))
        }
    }
    
    @IBAction func serachCoordinates(sender: AnyObject) {
        if var latitude = tfLatitude.text, longitude = tfLongitude.text {
            
            latitude = latitude.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            longitude = longitude.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if latitude == "" || longitude == ""{
                tfLatitude.text = "Type a latitude first!"
                tfLatitude.text = "Type a longitude first!"
                return
            }
            
            
            if longitude == "" {
                tfLatitude.text = "Type a latitude first!"
                return
            }
            
            view.endEditing(true)
            
            var methodParams = Utils.buildDefaultRequestParameters()
            methodParams["bbox"] = Utils.createBoundingBoxString(latitude: Double(latitude)!, longitude: Double(longitude)!)
            sendRequest(BASE_URL + Utils.escapedParameters(methodParams))
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

