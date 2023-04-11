//
//  FeedFeature.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 11/04/23.
//

import Foundation
internal final class FeedItemsMapper{
    
     struct Root:Decodable{
        let items:[Item]
    }

     struct Item:Decodable{
         let id:UUID
         let description:String?
         let location:String?
         let image:URL
        
        var item:FeedItems{
            FeedItems(id: id, description: description, location: location, imageURL: image)
        }
    }

    internal static func map(_ data:Data,_ response:HTTPURLResponse) throws -> [FeedItems]{
        guard response.statusCode == 200 else{
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return try JSONDecoder().decode(Root.self,from:data).items.map{$0.item}
    }
}
