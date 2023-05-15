//
//  LocalFeedItem.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 15/05/23.
//

import Foundation

public struct LocalFeedItems:Equatable{
    public let id:UUID
    public let description:String?
    public let location:String?
    public let imageURL:URL
    
    public init( id:UUID,
                 description:String?,
                 location:String?,
                 imageURL:URL){
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
