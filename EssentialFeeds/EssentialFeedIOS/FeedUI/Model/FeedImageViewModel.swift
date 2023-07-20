//
//  FeedImageViewModel.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 28/06/23.
//



import Foundation
import EssentialFeeds

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
