//
//  RemoteFeedItem.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 15/05/23.
//

import Foundation

 struct RemoteFeedItem:Decodable{
     let id:UUID
     let description:String?
     let location:String?
     let image:URL
}
