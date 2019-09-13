//
//  StringPath+Category.swift
//  WeiboSwift
//
//  Created by mc on 2019/8/18.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
extension String
{
    func cacheDir()->String{
        let path  = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).last!
        
        return path + "/" + self
        
    }
    func docDir() ->String{
        let path  = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).last!
        
        return path + "/" + self
        
    }
    func temDir()->String{
        let path  = NSTemporaryDirectory()
        
        return path + "/" + self
        
    }
    
}

