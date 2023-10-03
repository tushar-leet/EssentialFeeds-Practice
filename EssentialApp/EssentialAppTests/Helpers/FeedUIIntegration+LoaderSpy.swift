//
//  FeedUIIntegration+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by TUSHAR SHARMA on 19/09/23.
//

import Foundation
import EssentialFeeds
import EssentialFeedIOS
import EssentialApp
import Combine

class LoaderSpy:FeedImageDataLoader{
    
     // MARK: - FeedLoader

     private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
     private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
     
     var loadFeedCallCount:Int{
         feedRequests.count
     }

     private(set) var  cancelledImageURLs = [URL]()
     
     private struct TaskSpy:FeedImageDataLoaderTask{
         let cancelCallBack:()->()
         func cancel() {
             cancelCallBack()
         }
     }
        
     var loadedImageURLs: [URL] {
         return imageRequests.map { $0.url }
     }
     
 //        func load(completion: @escaping feedRequests) {
 //            completionArray.append(completion)
 //        }
     
     func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
         let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
         feedRequests.append(publisher)
         return publisher.eraseToAnyPublisher()
     }
     
     func completeFeedLoading(with feed:[FeedImage] = [],_ index:Int = 0){
        // completionArray[index](.success(feed))
         feedRequests[index].send(Paginated(items: feed))
     }
     
     func completeFeedLoadingWithError(at index:Int = 0){
         let error = NSError(domain: "a error", code: 0)
        // completionArray[index](.failure(error))
         feedRequests[index].send(completion: .failure(error))
     }
     
     // MARK: - FeedImageDataLoader
     
     func loadImageData(from url: URL,completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
         imageRequests.append((url, completion))
         return TaskSpy { [weak self] in
             self?.cancelledImageURLs.append(url)
         }
     }

     func completeImageLoading(with imageData:Data = Data(), at index:Int = 0){
         imageRequests[index].completion(.success(imageData))
     }
     
     func completeImageLoadingWithError(at index:Int = 0){
         let error = NSError(domain: "an error", code: 0)
         imageRequests[index].completion(.failure(error))
     }
 }
