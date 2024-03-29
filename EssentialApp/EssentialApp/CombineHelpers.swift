//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by TUSHAR SHARMA on 13/09/23.
//

import Foundation
import Combine
import EssentialFeeds

public extension LocalFeedLoader{
    typealias Publisher = AnyPublisher<[FeedImage],Error>
    func loadPublisher() -> Publisher{
        return Deferred{
            Future(self.load)
        }.eraseToAnyPublisher()
    }
}

public extension HTTPClient {
     typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>

     func getPublisher(url: URL) -> Publisher {
         var task: HTTPClientTask?

         return Deferred {
             Future { completion in
                 task = self.get(from: url, completion: completion)
             }
         }
         .handleEvents(receiveCancel: { task?.cancel() })
         .eraseToAnyPublisher()
     }
 }

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?
        
        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        }).eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}

extension Publisher {
    func caching(to cache:FeedCache) -> AnyPublisher<Output,Failure> where Output == [FeedImage]{
        handleEvents(receiveOutput:cache.saveIgnoringResult).eraseToAnyPublisher()
    }
    
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == Paginated<FeedImage> {
        handleEvents(receiveOutput:cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}


extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
    
    func saveIgnoringResult(_ page: Paginated<FeedImage>) {
        saveIgnoringResult(page.items)
    }
}

extension Publisher{
    func fallback(to fallbackPublisher:@escaping () -> AnyPublisher<Output,Failure>) -> AnyPublisher<Output,Failure>{
        self.catch{_ in fallbackPublisher()}.eraseToAnyPublisher()
    }
}

extension Publisher{
    func dispatchOnMainQueue() -> AnyPublisher<Output,Failure>{
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler()
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            action()
        }
        
        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}
