//
//  Utils.swift
//  Flicker Finder
//
//  Created by Daniele Vitali on 18/11/15.
//  Copyright © 2015 Daniele Vitali. All rights reserved.
//

import Foundation

public class Utils {
    
    public static let METHOD_NAME = "flickr.photos.search"
    public static let API_KEY = "0a0e10c407bc913ac05501cc1656648d"
    public static let GALLERY_ID = "5704-72157622566655097"
    public static let DATA_FORMAT = "json"
    public static let NO_JSON_CALLBACK = "1"
    public static let EXTRAS = "url_m"
    
    private static let BOUNDING_BOX_HALF_WIDTH = 1.0
    private static let BOUNDING_BOX_HALF_HEIGHT = 1.0
    private static let LAT_MIN = -90.0
    private static let LAT_MAX = 90.0
    private static let LON_MIN = -180.0
    private static let LON_MAX = 180.0
    
    static func buildDefaultRequestParameters() -> [String : String] {
        return [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "format": DATA_FORMAT,
            "gallery_id": GALLERY_ID,
            "nojsoncallback": NO_JSON_CALLBACK,
            "extras": EXTRAS
        ]
    }
    
    static func escapedParameters(parameters: [String : String]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let escapedValue = "\(value)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (urlVars.isEmpty ? "" : "?") + urlVars.joinWithSeparator("&")
    }
    
    static func parsePhotosJsonAndPickAnImage(data: NSData) -> Image? {
        let parsedJson = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
        if let photosDic = parsedJson["photos"] as? [String:AnyObject] {
            var photosCount = 0
            if let photosCountString = photosDic["total"] as? String {
                photosCount = Int(photosCountString)!
            }
            if photosCount > 0 {
                if let photosArray = photosDic["photo"] as? [[String : AnyObject]] {
                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                    let photoDic = photosArray[randomPhotoIndex] as [String : AnyObject]
                    let title = photoDic["title"] as? String
                    let imageUrl = photoDic[Utils.EXTRAS] as? String
                    return Image(title: title!, url: imageUrl!)
                }
            }
        }
        return nil
    }
    
    static func createBoundingBoxString(latitude latitude: Double, longitude: Double) -> String {
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottomLeftLon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottomLeftLat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let topRightLon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let topRightLat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottomLeftLon),\(bottomLeftLat),\(topRightLon),\(topRightLat)"
    }
    
}