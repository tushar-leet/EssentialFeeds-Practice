//
//  FeedStoreSpy.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 17/05/23.
//

import Foundation
import EssentialFeeds

class FeedStoreSpy:FeedStore{
    typealias DeletionCompletion = (Error?) -> ()
    typealias InsertCompletion = (Error?) -> ()
    typealias RetrieveCompletion = (RetrieveCachedFeedResult) -> ()

    enum ReceivedMessages:Equatable{
        case deleteCachedFeed
        case insert([LocalFeedImage],Date)
        case retrieve
    }

    private var deletionCompletion = [DeletionCompletion]()
    private var insertCompletion = [InsertCompletion]()
    private var retrieveCompletion = [RetrieveCompletion]()
    private(set) var receivedMessages = [ReceivedMessages]()

    func deleteCachedFeed(completion:@escaping DeletionCompletion){
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }

    func completeDeletion(with error:Error?, at index:Int = 0){
        deletionCompletion[index](error)
    }

    func completeDeletionSuccessfully(at index:Int = 0){
        deletionCompletion[index](nil)
    }

    func insert(_ feeds:[LocalFeedImage],timestamp:Date,completion:@escaping InsertCompletion){
        receivedMessages.append(.insert(feeds, timestamp))
        insertCompletion.append(completion)
    }

    func completeInsertion(with error:Error?, at index:Int = 0){
        insertCompletion[index](error)
    }

    func completeInsertionSuccessfully(at index:Int = 0){
        insertCompletion[index](nil)
    }
    
    func retrieve(completion:@escaping RetrieveCompletion) {
        retrieveCompletion.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrievel(with error:Error, at index:Int = 0){
        retrieveCompletion[index](.failure(error))
    }
    
    func completeRetrievelWithEmptyCache(at index:Int = 0){
        retrieveCompletion[index](.empty)
    }
    
    func completeRetrievel(with feed:[LocalFeedImage],timestamp:Date,at index:Int = 0){
        retrieveCompletion[index](.found(feed:feed,timestamp:timestamp))
    }
}
