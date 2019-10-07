//
//  HTTPURLResponse+Extension.swift
//  ClassicPhotos
//
//  Created by Xinbo Wu on 10/6/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    var hasSuccessStatusCode: Bool {
      return 200...299 ~= statusCode
    }
}
