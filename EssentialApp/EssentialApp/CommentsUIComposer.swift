//
//  FeedUIComposer.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 26/06/23.
//

import EssentialFeeds
import UIKit
import Combine
import EssentialFeedIOS

public final class CommentsUIComposer {
     private init() {}

    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
         
        let presentationAdapter = LoadResourcePresentationAdapter<[ImageComment],CommentViewAdapter>(loader: commentsLoader)
         let controller = makeCommentsViewController(
                      title: ImageCommentsPresenter.title)
        controller.onRefresh = presentationAdapter.loadResource
        presentationAdapter.presenter = LoadResourcePresenter(errorView: WeakRefVirtualProxy(object: controller), loadingView: WeakRefVirtualProxy(object: controller), resourceView: CommentViewAdapter(controller: controller), mapper: {ImageCommentsPresenter.map($0)})
         return controller
     }
    
    private static func makeCommentsViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.title = title
        return controller
    }
 }

private final class CommentViewAdapter:ResourceView{

    private weak var controller:ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }

    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
            CellController(id: viewModel, ImageCommentCellController(model: viewModel))
        })
    }
}

