//
//  RemoteLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 15/09/23.
//

import Foundation

public class RemoteLoader:FeedLoader{
    
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
                completion(RemoteLoader.map(data: data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
    
    private static func map(data:Data,response:HTTPURLResponse) -> Result{
        do{
            let items = try FeedItemsMapper.map(data, from: response)
             return .success(items)
        }catch{
            return .failure(Error.invalidData)
        }
    }
}
