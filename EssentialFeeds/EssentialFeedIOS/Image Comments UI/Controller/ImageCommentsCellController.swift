//
//  ImageCommentsCellController.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 18/09/23.
//

import UIKit
import EssentialFeeds

public class ImageCommentCellController:NSObject,UITableViewDataSource{
  
    private let model: ImageCommentViewModel
    
    public init(model:ImageCommentViewModel){
        self.model = model
    }
    
//    public func view(in tableView: UITableView) -> UITableViewCell {
//        let cell: ImageCommentCell = tableView.dequeueReusableCell()
//        cell.messageLabel.text = model.message
//        cell.usernameLabel.text = model.username
//        cell.dateLabel.text = model.date
//        return cell
//    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }
}
