//
//  ImageCache.swift
//  PureImage
//
//  Created by Miaoqi Wang on 2021/6/26.
//

import Foundation
import UIKit

class ImageCache: NSDiscardableContent  {
    var image: UIImage?
    
    init(image: UIImage) {
        self.image = image
    }
    
    func beginContentAccess() -> Bool {
        return image != nil
    }
    
    func discardContentIfPossible() {
        image = nil
    }
    
    func isContentDiscarded() -> Bool {
        return image == nil
    }
    
    func endContentAccess() {}
}

class ImageCacheManager {
    private let cache: NSCache<NSString, ImageCache>
    static let shared = ImageCacheManager()
    init() {
        self.cache = NSCache()
        self.cache.totalCostLimit = 100 * 1_000 * 1_000 * 1_000
    }
    
    func setImage(_ image: UIImage, key: String) {
        let imageCache = ImageCache(image: image)
        cache.setObject(imageCache, forKey: key as NSString)
    }
    
    func image(with key: String) -> UIImage? {
        cache.object(forKey: key as NSString)?.image
    }
}
