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
            case let .success(data,response):
                do {
                    let items = try FeedItemsMapper.map(data,response)
                    completion(.success(items))
                }catch{
                    completion(.failure(.invalidData))
                }
            case .error:
                completion(.failure(.connectivity))
            }
        })
    }
}

private struct Root:Decodable{
    let items:[Item]
}

private struct Item:Decodable{
     let id:UUID
     let description:String?
     let location:String?
     let image:URL
    
    var item:FeedItems{
        FeedItems(id: id, description: description, location: location, imageURL: image)
    }
}

private class FeedItemsMapper{
    static func map(_ data:Data,_ response:HTTPURLResponse) throws -> [FeedItems]{
        guard response.statusCode == 200 else{
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return try JSONDecoder().decode(Root.self,from:data).items.map{$0.item}
    }
}
