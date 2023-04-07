//
//  RemoteFeedLoaderApi.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 07/04/23.
//

import Foundation

public enum HTTPClientResult{
    case success(HTTPURLResponse)
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
    
    public init(url:URL,client:HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion:@escaping (Error) -> Void = {_ in}){
        client.get(url: url, completion: { result in
            switch result{
            case .success:
                completion(.invalidData)
            case .error:
                completion(.connectivity)
            }
        })
    }
}
