//
//  FeedViewController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 14/06/23.
//

import Foundation
import UIKit
import EssentialFeeds

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController:UITableViewController,UITableViewDataSourcePrefetching,ResourceLoadingView,FeedErrorView {
    
    public var delegate:FeedViewControllerDelegate?
    private var loadingControllers = [IndexPath: FeedImageCellController]()
    @IBOutlet private(set) public var errorView: ErrorView?
    private var tableModel = [FeedImageCellController](){
        didSet{
            tableView.reloadData()
        }
    }
    private var imageLoader:FeedImageDataLoader?
    var cellControllers = [IndexPath:FeedImageCellController]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }

    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: EssentialFeeds.FeedErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    public func display(_ cellControllers: [FeedImageCellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRow: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRow: indexPath).preload()
        }
    }
    
    private func cellController(forRow indexPath:IndexPath) -> FeedImageCellController{
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath:IndexPath){
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
}
