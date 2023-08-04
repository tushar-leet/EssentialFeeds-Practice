//
//  FeedErrorViewModel.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 01/08/23.
//

import Foundation

public struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
