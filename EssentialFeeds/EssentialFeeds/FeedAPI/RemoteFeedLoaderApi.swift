//
//  RemoteFeedLoaderApi.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 07/04/23.
//

import Foundation


public class RemoteFeedLoader{
    
    private let client:HTTPClient
    private let url:URL
    
    public enum Error:Swift.Error{
        case connectivity
        case invalidData
    }
    
    public enum Result:Equatable{
        case  success([FeedItems])
        case  failure(Error)
    }
    
    public init(url:URL,client:HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion:@escaping (Result) -> Void = {_ in}){
        client.get(url: url, completion: { result in
            switch result{
            case let .success(data,response):
                completion(FeedItemsMapper.map(data, from: response))
            case .error:
                completion(.failure(.connectivity))
            }
        })
    }
}


