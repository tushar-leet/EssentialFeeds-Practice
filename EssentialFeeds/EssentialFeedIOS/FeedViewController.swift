//
//  FeedViewController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 14/06/23.
//

import Foundation
import UIKit
import EssentialFeeds

public final class FeedViewController:UITableViewController{
    
    public var loader: FeedLoader?
    
    public convenience init(loader:FeedLoader){
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load(){
        refreshControl?.beginRefreshing()
        loader?.load{ [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
