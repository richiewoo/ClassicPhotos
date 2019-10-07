//
//  Result.swift
//  ClassicPhotos
//
//  Created by Xinbo Wu on 10/6/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//

import Foundation

enum Result<T, U:Error> {
    case success(T)
    case failure(U)
}
