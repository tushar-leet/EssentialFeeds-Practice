//
//  RemoteFeedLoaderApi.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 07/04/23.
//

import Foundation


public class RemoteFeedLoader:FeedLoader{
    
    private let client:HTTPClient
    private let url:URL
    
    public enum Error:Swift.Error{
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    public init(url:URL,client:HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion:@escaping (Result) -> Void = {_ in}){
        client.get(from: url, completion: { [weak self] result in
            guard  self != nil else{
                return
            }
            switch result{
            case let .success(data,response):
                completion(RemoteFeedLoader.map(data: data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
    
    private static func map(data:Data,response:HTTPURLResponse) -> Result{
        do{
            let items = try FeedItemsMapper.map(data, from: response)
             return .success(items.toModels())
        }catch{
             return .failure(error)
        }
    }
}

extension Array where Element == RemoteFeedItem{
    func toModels() -> [FeedImage]{
        map{FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
    }
}


