//
//  RemoteFeedLoaderApi.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 07/04/23.
//

import Foundation

public enum HTTPClientResult{
    case success(Data,HTTPURLResponse)
    case error(Error)
}

public protocol HTTPClient{
    func get(url:URL,completion:@escaping (HTTPClientResult) -> Void)
}

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
            case let .success(data,_):
                if let _ = try? JSONSerialization.jsonObject(with: data){
                    completion(.success([]))
                }else{
                    completion(.failure(.invalidData))
                }
            case .error:
                completion(.failure(.connectivity))
            }
        })
    }
}
