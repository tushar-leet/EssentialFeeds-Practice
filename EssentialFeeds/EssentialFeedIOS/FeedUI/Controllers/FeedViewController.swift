//
//  FeedViewController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 14/06/23.
//

import Foundation
import UIKit
import EssentialFeeds


public final class FeedViewController:UITableViewController,UITableViewDataSourcePrefetching {
    
    private var refreshController: FeedRefreshViewController?
    var tableModel = [FeedImageCellController](){
        didSet{
            tableView.reloadData()
        }
    }
    private var imageLoader:FeedImageDataLoader?
    var cellControllers = [IndexPath:FeedImageCellController]()
    
    convenience init(refreshController:FeedRefreshViewController){
        self.init()
        self.refreshController =  refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }
 
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRow: indexPath).view()
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
       tableModel[indexPath.row]
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func cancelCellControllerLoad(forRowAt indexPath:IndexPath){
        cellController(forRow:indexPath).cancelLoad()
    }
}
