//
//  GiphyRequest.swift
//  GiphySearch
//
//  Created by Vladimir Kelin on 6/24/16.
//  Copyright © 2016 Vladimir Kelin. All rights reserved.
//

import Foundation

typealias GiphyResponseDictionary = Dictionary<String, AnyObject>
typealias GiphyRequestCompletionHandler = (requestURL: NSURL,
                                           rawResponse: NSData?,
                                           connectionError: NSError?,
                                           responseDictionary: GiphyResponseDictionary?) -> ()


class GiphyRequest
{
    static let baseURLStr = kGiphyBaseURLStr
    static let apiKey = kGiphyAPIKey
    
    let requestURL: NSURL
    var completionHandler: GiphyRequestCompletionHandler?
    
    private var _task: NSURLSessionTask? = nil
    
    /**
     Creates and starts a new request
     @param params URL parameters string separated by &
     @param completionHandler Will be called on main queue
     */
    required init(path: String, params: String, completionHandler: GiphyRequestCompletionHandler)
    {
        var URLStr = GiphyRequest.baseURLStr
        URLStr += path
        var extendedParams = "?api_key=\(GiphyRequest.apiKey)"
        if params != ""
        {
            extendedParams += "&"
            extendedParams += params
        }
        URLStr += extendedParams
        
        requestURL = NSURL(string: URLStr)!
        self.completionHandler = completionHandler
        
        _start()
    }
    
    func cancel() {
        _task?.cancel()
        _task = nil;
        completionHandler = nil
    }
    
    private func _start() {
        _task = NSURLSession.sharedSession().dataTaskWithURL(requestURL, completionHandler: {
            (data, response, error) in
            
            if error != nil
            {
                self._complete(connectionError: error, data: data, responseDict: nil)
            }
            else if data != nil
            {
                // Try to parse JSON
                var responseDict: GiphyResponseDictionary?
                do {
                    responseDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) as? GiphyResponseDictionary
                } catch {
                    responseDict = nil
                    print("Error in file: \(#file), function: \(#function): failed to parse JSON!")
                }
                
                self._complete(connectionError: nil, data: data, responseDict: responseDict)
            }
        })
        
        _task?.resume()
    }
    
    private func _complete(connectionError connectionError: NSError?, data: NSData?, responseDict: GiphyResponseDictionary?) {
        if let unwrappedCompletion = completionHandler
        {
            dispatch_async(dispatch_get_main_queue(), { 
                unwrappedCompletion(
                    requestURL: self.requestURL,
                    rawResponse: data,
                    connectionError: connectionError,
                    responseDictionary: responseDict
                )
            })
            
            completionHandler = nil
        }
        
        _task = nil
    }
}

// MARK: - Convinience factory methods
extension GiphyRequest {
    static func trendyRequest(maxGifsCount limit: Int, completionHandler: GiphyRequestCompletionHandler) -> GiphyRequest
    {
        let paramsStr = "limit=\(limit)"
        let request = GiphyRequest(path: "/v1/gifs/trending", params: paramsStr, completionHandler: completionHandler)
        return request
    }
}