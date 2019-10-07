//
//  PhotoListViewController.swift
//  ClassicPhotos
//
//  Created by Xinbo Wu on 10/6/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//

import UIKit

class PhotoListViewController: UITableViewController {
    
    private var viewModel: PhotoListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "Classic Photos"
        
        viewModel = PhotoListViewModel(delegate: self)
        viewModel.fetchPhotoData()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.totalPhotos
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(style: .medium)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        let photoRecord = viewModel.photoRecord(at: indexPath)
        
        cell.textLabel?.text = photoRecord.name
        cell.imageView?.image = photoRecord.image
        
        switch photoRecord.state {
        case .failed:
            indicator.stopAnimating()
        case .filtered:
            indicator.stopAnimating()
        case .new, .downloaded:
            if !tableView.isDragging && !tableView.isDecelerating {
                viewModel.startOperation(for: indexPath)
             }
        }

        return cell
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        PhotoDataProvider.shared.suspendAllOperations()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2
        if !decelerate {
            if let pathsArray = tableView.indexPathsForVisibleRows {
                viewModel.loadImagesForOnscreenCells(indexPaths: pathsArray)
            }
            
            PhotoDataProvider.shared.resumeAllOperations()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 3
        if let pathsArray = tableView.indexPathsForVisibleRows {
            viewModel.loadImagesForOnscreenCells(indexPaths: pathsArray)
        }
        PhotoDataProvider.shared.resumeAllOperations()
    }
}


extension PhotoListViewController: PhotoListViewModelDelegate {
    func onFetchCompleted(with photoRecords: [PhotoRecord]) {
        self.tableView.reloadData()
    }
    
    func onFetchFailed(with reason: String) {
        let alertController = UIAlertController(title: "Oops", message: reason, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onOperationCompleted(for indexPath: IndexPath) {
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
