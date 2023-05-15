//
//  RemoteFeedItem.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 15/05/23.
//

import Foundation

internal struct RemoteFeedItem:Decodable{
    internal let id:UUID
    internal let description:String?
    internal let location:String?
    internal let image:URL
}
