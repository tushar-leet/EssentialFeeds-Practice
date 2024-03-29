//
//  LoadResourcePresenter.swift
//  EssentialFeeds
//
//  Created by TUSHAR SHARMA on 16/09/23.
//

import Foundation

public protocol ResourceView{
    associatedtype ResourceViewModel
    func display(_ viewModel:ResourceViewModel)
}

public final class LoadResourcePresenter<Resource,View:ResourceView>{
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    private let errorView: ResourceErrorView
    private let loadingView:ResourceLoadingView
    private let resourceView:View
    private let mapper:Mapper
    
    public init(errorView: ResourceErrorView,
         loadingView:ResourceLoadingView,
         resourceView:View,
         mapper: @escaping Mapper) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    
    public static  var loadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Error message displayed when we can't load resource from the server")
    }
    
    public func didStartLoading(){
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource:Resource){
        do{
            resourceView.display(try mapper(resource))
            loadingView.display(ResourceLoadingViewModel(isLoading: false))
        }catch{
            didFinishLoading(with: error)
        }
    }
    
    public func didFinishLoading(with error:Error){
        errorView.display(.error(message: Self.loadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
