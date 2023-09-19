//
//  FeedViewControllerTest+Localization.swift
//  EssentialFeedIOSTests
//
//  Created by TUSHAR SHARMA on 31/07/23.
//

import Foundation
import XCTest
import EssentialFeeds

extension FeedUIIntegrationTests {
    private class DummyView:ResourceView{
        func display(_ viewModel: Any) {}
    }
    var loadError:String{
        LoadResourcePresenter<Any,DummyView>.loadError
    }
    
    var feedTitle:String{
        FeedPresenter.title
    }
    
    var commentTitle:String{
        ImageCommentsPresenter.title
    }
}
