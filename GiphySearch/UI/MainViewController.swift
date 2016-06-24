//
//  MainViewController.swift
//  GiphySearch
//
//  Created by Vladimir Kelin on 6/24/16.
//  Copyright © 2016 Vladimir Kelin. All rights reserved.
//

import Foundation
import UIKit


class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var gifs = [GIFImageData]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        
        self.loadTrendy()
    }
    
    func loadTrendy() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        GiphyRequest.trendyRequest(maxGifsCount: 50) {
            [unowned self] (requestURL, rawResponse, connectionError, responseDictionary) in
            
            print(responseDictionary)
            var newGifImagesData = [GIFImageData]()
            
            if let gifsArray = responseDictionary?["data"] as? Array<Dictionary<String, AnyObject>>
            {
                for gifDict in gifsArray
                {
                    if let gifData = GIFData(dictionary: gifDict)
                    {
                        newGifImagesData.append(gifData.fixedHeightImageData)
                    }
                }
            }
            
            self.gifs = newGifImagesData
            self.activityIndicator.stopAnimating()
            self.collectionView.reloadData()
        }
    }
    
    
    // MARK: - Collection View
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("gif_cell", forIndexPath: indexPath)
        return cell
    }
    
    
    // MARK: - Search Bar Delegate
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return false
    }
}