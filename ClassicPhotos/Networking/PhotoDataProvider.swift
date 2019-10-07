//
//  PhotoDataProvider.swift
//  ClassicPhotos
//
//  Created by Xinbo Wu on 10/6/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//

import Foundation

final class PhotoDataProvider {
    
    static var shared: PhotoDataProvider = {
        return PhotoDataProvider()
    }()
    
    lazy var dataSourceURL: URL = {
      return URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")!
    }()
    
    var photoRecords: [PhotoRecord] = []
    
    let session: URLSession
    let pendingOperations: PendingOperations = PendingOperations()
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    var totalCount: Int {
        return photoRecords.count
    }
    
    func photoRecord(at indexPath: IndexPath) -> PhotoRecord {
        return photoRecords[indexPath.row]
    }
    
    func fetchPhotoData(url: URL, completion: @escaping (Result<[PhotoRecord], DataResponseError>) -> Void )  {
        
        let request = URLRequest(url: dataSourceURL)
        
        session.dataTask(with: request) { data, response, error in
            
            guard let data = data else {
                completion(Result.failure(.network))
                return
            }
            
            do {
                let datasorceDictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: String]
                
                for (name, value) in datasorceDictionary {
                    let url = URL(string: value)
                    if let url = url {
                        self.photoRecords.append(PhotoRecord(name: name, url: url))
                    }
                }
                
                completion(Result.success(self.photoRecords))
            }
            catch let error {
                completion(Result.failure(DataResponseError.decoding))
            }
        }.resume()
    }
    
    func startOperations(at indexPath: IndexPath, completionBlock: @escaping (() -> Void)) {
        let photoRecord = photoRecords[indexPath.row]
        
        switch photoRecord.state {
        case .new:
            startDownload(at: indexPath, completionBlock: completionBlock)
        case .downloaded:
            startFiltration(at: indexPath, completionBlock: completionBlock)
        default:
            NSLog("Do nothing")
        }
    }
    
    func startOperations(at indexPaths: [IndexPath], completionBlock: @escaping ((IndexPath) -> Void)) {
        var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
          allPendingOperations.formUnion(pendingOperations.filtrationsInProgress.keys)
          
          var toBeCancelled = allPendingOperations
          let visiblePaths = Set(indexPaths)
          toBeCancelled.subtract(visiblePaths)
          
          var toBeStarted = visiblePaths
          toBeStarted.subtract(allPendingOperations)
          
          for indexPath in toBeCancelled {
              if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                  pendingDownload.cancel()
              }
              pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
              if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
                  pendingFiltration.cancel()
              }
              pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
          }
          
          for indexPath in toBeStarted {
              startOperations(at: indexPath as IndexPath) {
                  completionBlock(indexPath)
              }
          }
    }
    
    func startDownload(at indexPath: IndexPath, completionBlock: @escaping (() -> Void)) {
        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        
        let photoRecord = photoRecords[indexPath.row]
        
        let downloader = ImageDownloader(photoRecord)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
             
            completionBlock()
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func startFiltration(at indexPath: IndexPath, completionBlock: @escaping (() -> Void)) {
        guard pendingOperations.filtrationsInProgress[indexPath] == nil else {
            return
        }
        
        let photoRecord = photoRecords[indexPath.row]
        
        let filterer = ImageFiltration(photoRecord)
        filterer.completionBlock = {
            if filterer.isCancelled {
                return
            }
            
            self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
            
            completionBlock()
        }
        
        pendingOperations.filtrationsInProgress[indexPath] = filterer
        pendingOperations.filtrationQueue.addOperation(filterer)
    }
    
    func suspendAllOperations() {
        pendingOperations.downloadQueue.isSuspended = true
        pendingOperations.filtrationQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        pendingOperations.downloadQueue.isSuspended = false
        pendingOperations.filtrationQueue.isSuspended = false
    }
}
