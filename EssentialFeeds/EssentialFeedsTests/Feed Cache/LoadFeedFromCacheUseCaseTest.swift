//
//  LoadFeedFromCacheUseCaseTest.swift
//  EssentialFeedsTests
//
//  Created by TUSHAR SHARMA on 16/05/23.
//

import XCTest
import EssentialFeeds

final class LoadFeedFromCacheUseCaseTest: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation(){
        let (_,store) = makeSut()
        XCTAssertEqual(store.receivedMessages,[])
    }
    
    private func makeSut(currentDate:@escaping ()->Date = Date.init,file:StaticString = #filePath, line:UInt = #line) -> (LocalFeedLoader,FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(store)
        return (sut,store)
    }
    
    class FeedStoreSpy:FeedStore{
        typealias DeletionCompletion = (Error?) -> ()
        typealias InsertCompletion = (Error?) -> ()
       
        enum ReceivedMessages:Equatable{
            case deleteCachedFeed
            case insert([LocalFeedImage],Date)
        }
        
        private var deletionCompletion = [DeletionCompletion]()
        private var insertCompletion = [InsertCompletion]()
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
    }
}
