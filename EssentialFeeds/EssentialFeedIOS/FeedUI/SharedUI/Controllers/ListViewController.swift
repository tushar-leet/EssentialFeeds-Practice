//
//  FeedViewController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 14/06/23.
//

import Foundation
import UIKit
import EssentialFeeds

//public protocol CellController{
//    func view(in:UITableView) -> UITableViewCell
//    func preload()
//    func cancelLoad()
//}
//
//public extension CellController{
//    func preload(){}
//    func cancelLoad(){}
//}


public final class ListViewController:UITableViewController,UITableViewDataSourcePrefetching,ResourceLoadingView,ResourceErrorView {
    
    public var onRefresh:(()->Void)?
    private var loadingControllers = [IndexPath: CellController]()
    @IBOutlet private(set) public var errorView: ErrorView?
    private var tableModel = [CellController](){
        didSet{
            tableView.reloadData()
        }
    }
    private var imageLoader:FeedImageDataLoader?
    var cellControllers = [IndexPath:CellController]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }

    @IBAction private func refresh() {
        onRefresh?()
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: EssentialFeeds.ResourceErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    public func display(_ cellControllers: [CellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ds = cellController(forRow: indexPath).dataSource
        return ds.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = removeLoadingController(forRowAt: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(forRow: indexPath).dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    private func cellController(forRow indexPath:IndexPath) -> CellController{
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = removeLoadingController(forRowAt: indexPath)?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func removeLoadingController(forRowAt indexPath:IndexPath) -> CellController?{
        let controller =  loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
}
