//
//  FeedImageViewModel.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 03/08/23.
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        return location != nil
    }
}
