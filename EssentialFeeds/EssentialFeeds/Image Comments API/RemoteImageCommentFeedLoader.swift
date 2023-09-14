//
//  RemoteImageCommentFeedLoader.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 14/09/23.
//

import Foundation

public class RemoteImageCommentLoader{
    
    private let client:HTTPClient
    private let url:URL
    
    public enum Error:Swift.Error{
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[ImageComment],Swift.Error>
    
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
                completion(RemoteImageCommentLoader.map(data: data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
    
    private static func map(data:Data,response:HTTPURLResponse) -> Result{
        do{
            let items = try ImageCommentMapper.map(data, from: response)
             return .success(items)
        }catch{
             return .failure(error)
        }
    }
}



