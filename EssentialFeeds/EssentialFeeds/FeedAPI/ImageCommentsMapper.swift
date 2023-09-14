//
//  ImageCommentsMapper.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 14/09/23.
//

import Foundation

final class ImageCommentMapper{
   
    struct Root:Decodable{
       let items:[RemoteFeedItem]
   }

    static func map(_ data:Data,from response:HTTPURLResponse)  throws -> [RemoteFeedItem]{
       guard response.statusCode == 200,let root = try? JSONDecoder().decode(Root.self,from:data) else{
             throw RemoteImageCommentLoader.Error.invalidData
       }
       return root.items
   }
}
