//
//  PhotoRecord.swift
//  ClassicPhotos
//
//  Created by Xinbo Wu on 10/6/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//

import Foundation
import UIKit

enum PhotoRecordState {
    case new, downloaded, filtered, failed
}

class PhotoRecord {
    let name: String
    let url: URL
    
    var state: PhotoRecordState = .new
    var image: UIImage? = UIImage(named: "Placeholder")
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}
