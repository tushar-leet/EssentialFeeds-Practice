//
//  FeedRefreshViewController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 26/06/23.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
     func didRequestFeedRefresh()
 }

final class FeedRefreshViewController: NSObject,FeedLoadingView {
   
    @IBOutlet private var view:UIRefreshControl?
    
    var delegate: FeedRefreshViewControllerDelegate?

     @IBAction @objc func refresh() {
         delegate?.didRequestFeedRefresh()
     }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading{
            view?.beginRefreshing()
        }else{
            view?.endRefreshing()
        }
    }
 }
