//
//  FeedItems.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 06/04/23.
//

import Foundation

public struct FeedItems:Equatable{
    let id:UUID
    let description:String?
    let location:String?
    let imageUrl:URL
}
