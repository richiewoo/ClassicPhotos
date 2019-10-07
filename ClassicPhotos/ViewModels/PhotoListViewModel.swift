//
//  PhotoListViewModel.swift
//  ClassicPhotos
//
//  Created by Xinbo Wu on 10/6/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//

import Foundation

protocol PhotoListViewModelDelegate: class {
    func onFetchCompleted(with photoRecords: [PhotoRecord])
    func onFetchFailed(with reason: String)
    func onOperationCompleted(for indexPath: IndexPath)
}


class PhotoListViewModel {
    private lazy var photoDataProvider = {
        return PhotoDataProvider.shared
    }()
    
    private weak var delegate: PhotoListViewModelDelegate?
    
    var isLoadingData: Bool = false
    
    init(delegate: PhotoListViewModelDelegate) {
        self.delegate = delegate
    }
    
    var totalPhotos: Int {
        return photoDataProvider.totalCount
    }
    
    func photoRecord(at indexPath: IndexPath) -> PhotoRecord {
        return photoDataProvider.photoRecord(at: indexPath)
    }
    
    func fetchPhotoData() {
        
        guard !isLoadingData else {
            return
        }
        
        isLoadingData = true
        
        photoDataProvider.fetchPhotoData(url: photoDataProvider.dataSourceURL) { [unowned self](result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.delegate?.onFetchCompleted(with: response)
                }
            case .failure(let responseErr):
                DispatchQueue.main.async {
                    self.delegate?.onFetchFailed(with: responseErr.reason)
                }
            }
        }
    }
    
    func startOperation(for indexPath: IndexPath) {
        photoDataProvider.startOperations(at: indexPath) {
            DispatchQueue.main.async {
                self.delegate?.onOperationCompleted(for: indexPath)
            }
        }
    }
    
    func loadImagesForOnscreenCells(indexPaths:[IndexPath]) {
        photoDataProvider.startOperations(at: indexPaths) { (indexPath) in
                        DispatchQueue.main.async {
                self.delegate?.onOperationCompleted(for: indexPath)
            }
        }
    }
}
