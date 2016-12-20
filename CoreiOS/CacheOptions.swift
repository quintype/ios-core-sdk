//
//  CacheOptions.swift
//  CoreiOS
//
//  Created by Albin CR on 12/14/16.
//  Copyright © 2016 Albin CR. All rights reserved.
//

import Foundation


public  enum cacheOption {
    
    case none
    case cacheToMemoryWithTime(min:Int)
    case cacheToMemoryAndDiskWithTime(min:Int)
    case loadOldCacheAndReplaceWithNew
    
    
    var value: [String:Int]? {
        
        switch self {
            
        case .none:
            return nil
        case .cacheToMemoryWithTime(let min):
            return [Constants.cache.cacheToMemoryWithTime: min]
        case .cacheToMemoryAndDiskWithTime(let min):
            return [Constants.cache.cacheToMemoryAndDiskWithTime: min]
        case .loadOldCacheAndReplaceWithNew:
            return [Constants.cache.loadOldCacheAndReplaceWithNew:0]
        }
   }
}




