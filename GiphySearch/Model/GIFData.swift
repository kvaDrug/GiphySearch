//
//  GIFData.swift
//  GiphySearch
//
//  Created by Vladimir Kelin on 6/24/16.
//  Copyright © 2016 Vladimir Kelin. All rights reserved.
//

import Foundation


class GIFImageData
{
    let URL: String
    let width: Double
    let height: Double
    
    init?(dictionary: Dictionary<String, AnyObject>)
    {
        guard
            let stringURL = dictionary["url"] as? String,
            let doubleWidht = (dictionary["width"] as? NSString)?.doubleValue,
            let doubleHeight = (dictionary["height"] as? NSString)?.doubleValue
        else
        {
            return nil
        }
        
        URL = stringURL
        width = doubleWidht
        height = doubleHeight
    }
}

class GIFData
{
    let id: String
    let rating: String
    let importDate: NSDate
    let trendingDate: NSDate
    let trended: Bool
    let fixedHeightImageData: GIFImageData
    let originalImageData: GIFImageData
    
    init?(dictionary: Dictionary<String, AnyObject>)
    {
        guard
            let idStr = dictionary["id"] as? String,
            let ratingStr = dictionary["rating"] as? String,
            let importDateStr = dictionary["import_datetime"] as? String,
            let trendingDateStr = dictionary["trending_datetime"] as? String,
            let images = dictionary["images"] as? Dictionary<String, AnyObject>
        else
        {
            return nil
        }
        
        id = idStr
        rating = ratingStr
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard
            let anImportDate = dateFormatter.dateFromString(importDateStr),
            let aTrendingDate = dateFormatter.dateFromString(trendingDateStr)
        else
        {
            return nil
        }
        importDate = anImportDate
        trendingDate = aTrendingDate
        trended = (aTrendingDate.compare(NSDate(timeIntervalSince1970: 0.0)) == .OrderedDescending)
        
        guard
            let fixedHeightImageDataDict = images["fixed_height"] as? Dictionary<String, AnyObject>,
            let originalImageDataDict = images["original"] as? Dictionary<String, AnyObject>,
            let aFixedHeightImageData = GIFImageData(dictionary: fixedHeightImageDataDict),
            let anOriginalImageData = GIFImageData(dictionary: originalImageDataDict)
        else
        {
            return nil
        }
        fixedHeightImageData = aFixedHeightImageData
        originalImageData = anOriginalImageData
    }
}