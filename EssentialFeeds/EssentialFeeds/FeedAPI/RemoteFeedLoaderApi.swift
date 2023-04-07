//
//  RemoteFeedLoaderApi.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 07/04/23.
//

import Foundation

public protocol HTTPClient{
    func get(url:URL)
}

public class RemoteFeedLoader{
    
    private let client:HTTPClient
    private let url:URL
    
    public init(url:URL,client:HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(){
        client.get(url: url)
    }
}
