//
//  FeedFeature.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 11/04/23.
//

import Foundation


 final class FeedItemsMapper{
    
     struct Root:Decodable{
        private let items:[RemoteFeedItem]
         
         private struct RemoteFeedItem:Decodable{
             let id:UUID
             let description:String?
             let location:String?
             let image:URL
        }

         var images:[FeedImage]{
             items.map{FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
         }
    }

     static func map(_ data:Data,from response:HTTPURLResponse)  throws -> [FeedImage]{
        guard response.statusCode == 200,let root = try? JSONDecoder().decode(Root.self,from:data) else{
              throw RemoteFeedLoader.Error.invalidData
        }
         return  root.images
    }
}
