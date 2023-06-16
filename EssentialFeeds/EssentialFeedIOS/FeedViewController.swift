//
//  FeedViewController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 14/06/23.
//

import Foundation
import UIKit
import EssentialFeeds

public protocol FeedImageDataLoaderTask{
    func cancel()
}

public protocol FeedImageDataLoader{
    func loadImageData(from url:URL) -> FeedImageDataLoaderTask
}

public final class FeedViewController:UITableViewController{
    
    public var feedLoader: FeedLoader?
    private var tableModel = [FeedImage]()
    private var imageLoader:FeedImageDataLoader?
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    
    public convenience init(feedLoader:FeedLoader,imageLoader:FeedImageDataLoader){
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load(){
        refreshControl?.beginRefreshing()
        feedLoader?.load{ [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
                self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        tasks[indexPath] = imageLoader?.loadImageData(from: model.url)
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
