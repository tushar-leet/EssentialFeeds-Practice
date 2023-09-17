//
//  ImageCommentsCellController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 18/09/23.
//

import UIKit
import EssentialFeeds

public class ImageCommentCellController:CellController{
  
    private let model: ImageCommentViewModel?
    
    public init(model:ImageCommentViewModel){
        self.model = model
    }
    
    public func view(in: UITableView) -> UITableViewCell {
        UITableViewCell()
    }
    
    public func preload() {
        
    }
    
    public func cancelLoad() {
        
    }
    
}
