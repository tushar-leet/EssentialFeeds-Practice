//
//  LoadMoreCellController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 24/09/23.
//

import UIKit
import EssentialFeeds

public class LoadMoreCellController:NSObject,UITableViewDataSource,UITableViewDelegate{
    private let cell = LoadMoreCell()
    private let callback:()->Void
    
    public init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, willDisplay: UITableViewCell, forRowAt indexPath: IndexPath) {
        reloadIfNeeded()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reloadIfNeeded()
    }
    
    private func reloadIfNeeded() {
        guard !cell.isLoading else { return }
        callback()
    }
}

extension LoadMoreCellController:ResourceLoadingView,ResourceErrorView{
    public func display(_ viewModel: EssentialFeeds.ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
    
    public func display(_ isLoading: EssentialFeeds.ResourceLoadingViewModel) {
        cell.isLoading = isLoading.isLoading
    }
}
