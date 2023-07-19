//
//  FeedRefreshViewController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 26/06/23.
//

import UIKit

final class FeedRefreshViewController: NSObject,FeedLoadingView {
   
     private(set) lazy var view = loadView()
    
     private var presenter: FeedPresenter

     init(presenter: FeedPresenter) {
         self.presenter = presenter
     }

     @objc func refresh() {
         presenter.loadFeed()
     }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading{
            view.beginRefreshing()
        }else{
            view.endRefreshing()
        }
    }

    private func loadView() -> UIRefreshControl{
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
 }
