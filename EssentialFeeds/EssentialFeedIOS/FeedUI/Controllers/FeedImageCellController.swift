//
//  FeedImageCellController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 26/06/23.
//

import EssentialFeeds
import UIKit

public protocol FeedImageCellControllerDelegate {
     func didRequestImage()
     func didCancelImageRequest()
 }


public final class FeedImageCellController:FeedImageView,ResourceView,ResourceLoadingView,ResourceErrorView{
   
    public typealias ResourceViewModel = UIImage
    private let viewModel:FeedImageViewModel<UIImage>
    private let delegate: FeedImageCellControllerDelegate
    private  var cell: FeedImageCell?
    
    public init(viewModel:FeedImageViewModel<UIImage>,delegate: FeedImageCellControllerDelegate) {
             self.delegate = delegate
             self.viewModel = viewModel
         }
    
    func view(in tableView:UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.descriptionLabel.text = viewModel.description
        cell?.locationLabel.text = viewModel.location
        cell?.onRetry = delegate.didRequestImage
        delegate.didRequestImage()
        return cell!
    }
    
    public func display(_ viewModel: FeedImageViewModel<UIImage>) {}
    
    func preload(){
        delegate.didRequestImage()
    }
    
    func cancelLoad(){
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }

    private func releaseCellForReuse() {
        cell = nil
    }
    
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ isLoading: EssentialFeeds.ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: EssentialFeeds.ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
    }
}

