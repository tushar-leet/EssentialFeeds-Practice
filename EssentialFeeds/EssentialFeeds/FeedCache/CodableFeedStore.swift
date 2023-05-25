//
//  CodableFeedStore.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 25/05/23.
//

import Foundation

public class CodableFeedStore:FeedStore{
    
    private struct Cache:Codable{
        let feed:[CodableFeedImage]
        let timeStamp:Date
        
        var localFeed:[LocalFeedImage]{
            feed.map{$0.local}
        }
    }
    
    private struct CodableFeedImage:Codable{
        private let id:UUID
        private let description:String?
        private let location:String?
        private let url:URL
        
        init(_ image:LocalFeedImage)  {
            id = image.id
            description = image.description
            location = image.description
            url = image.url
        }
        
        var local:LocalFeedImage{
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL:URL
    
    public init(storeURL:URL){
        self.storeURL = storeURL
    }
    
    public func retrieve(completion:@escaping FeedStore.RetrieveCompletion){
        guard let data = try? Data(contentsOf: storeURL) else{
            completion(.empty)
            return
        }
        do{
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timeStamp))
        }catch{
            completion(.failure(error))
        }
    }
    
    public func insert(_ feeds:[LocalFeedImage],timestamp:Date,completion:@escaping FeedStore.InsertCompletion){
        do{
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(Cache(feed: feeds.map(CodableFeedImage.init), timeStamp: timestamp))
            try encoded.write(to: storeURL)
            completion(nil)
        }catch{
            completion(error)
        }
    }
    
    public func deleteCachedFeed(completion:@escaping FeedStore.DeletionCompletion){
        guard FileManager.default.fileExists(atPath: storeURL.path) else{
            return completion(nil)
        }
        
        do{
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch{
            completion(error)
        }
    }
}
