//
//  FeedSnapshotTest.swift
//  EssentialFeedIOSTests
//
//  Created by TUSHAR SHARMA on 10/09/23.
//

//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeedIOS
@testable import EssentialFeeds

class FeedSnapshotTests: XCTestCase {
    
//    func test_emptyFeed() {
//        let sut = makeSUT()
//
//        sut.display(emptyFeed())
//
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED_light")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_dark")
//    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
    }
    
//    func test_feedWithErrorMessage() {
//        let sut = makeSUT()
//        
//        sut.display(.error(message: "This is a\nmulti-line\nerror message"))
//        
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_MESSAGE_light")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_dark")
//    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green)
            )
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(
                description: nil,
                location: "Cannon Street, London",
                image: nil
            ),
            ImageStub(
                description: nil,
                location: "Brighton Seafront",
                image: nil
            )
        ]
    }
    
//    private func emptyFeed() -> [FeedImageCellController] {
//        return []
//    }

}

struct SnapshotConfiguration {
     let size: CGSize
     let safeAreaInsets: UIEdgeInsets
     let layoutMargins: UIEdgeInsets
     let traitCollection: UITraitCollection

     static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
         return SnapshotConfiguration(
             size: CGSize(width: 375, height: 667),
             safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
             layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
             traitCollection: UITraitCollection(traitsFrom: [
                 .init(forceTouchCapability: .available),
                 .init(layoutDirection: .leftToRight),
                 .init(preferredContentSizeCategory: .medium),
                 .init(userInterfaceIdiom: .phone),
                 .init(horizontalSizeClass: .compact),
                 .init(verticalSizeClass: .regular),
                 .init(displayScale: 2),
                 .init(displayGamut: .P3),
                 .init(userInterfaceStyle: style)
             ]))
     }
 }

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let cellController = FeedImageCellController(viewModel:stub.viewModel,delegate: stub)
            stub.controller = cellController
            return cellController
        }
        
        display(cells)
    }
}

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone8(style: .light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }
    
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel
    weak var controller: FeedImageCellController?
    let image:UIImage?
    
    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(
            description: description,
            location: location)
        self.image = image
    }
    
    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))
        if let image = image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(ResourceErrorViewModel(message: "any"))
        }
    }
    
    func didCancelImageRequest() {}
}
