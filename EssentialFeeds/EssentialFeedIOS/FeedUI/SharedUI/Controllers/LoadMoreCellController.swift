//
//  LoadMoreCellController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 24/09/23.
//

import UIKit
import EssentialFeeds

public class LoadMoreCellController:NSObject,UITableViewDataSource{
    private let cell = LoadMoreCell()
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        LoadMoreCell()
    }
}

extension LoadMoreCellController:ResourceLoadingView{
    public func display(_ isLoading: EssentialFeeds.ResourceLoadingViewModel) {
        cell.isLoading = isLoading.isLoading
    }
}
