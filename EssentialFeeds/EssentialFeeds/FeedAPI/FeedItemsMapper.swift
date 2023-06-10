//
//  FeedFeature.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 11/04/23.
//

import Foundation


 final class FeedItemsMapper{
    
     struct Root:Decodable{
        let items:[RemoteFeedItem]
    }

     static func map(_ data:Data,from response:HTTPURLResponse)  throws -> [RemoteFeedItem]{
        guard response.statusCode == 200,let root = try? JSONDecoder().decode(Root.self,from:data) else{
              throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
