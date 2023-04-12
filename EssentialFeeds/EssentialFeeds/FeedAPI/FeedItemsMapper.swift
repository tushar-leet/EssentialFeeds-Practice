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
         
         var feed:[FeedItems]{
             items.map{$0.item}
         }
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

    internal static func map(_ data:Data,from response:HTTPURLResponse)  -> RemoteFeedLoader.Result{
        guard response.statusCode == 200,let root = try? JSONDecoder().decode(Root.self,from:data) else{
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }
}
