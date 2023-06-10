//
//  FeedViewController.swift
//  Prototype
//
//  Created by TUSHAR SHARMA on 11/06/23.
//

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

class FeedViewController: UITableViewController {
    
    private let feed = FeedImageViewModel.prototypeFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
                 let model = feed[indexPath.row]
                 cell.configure(with: model)
                 return cell
    }
}

extension FeedImageCell {
     func configure(with model: FeedImageViewModel) {
         locationLabel.text = model.location
         locationContainer.isHidden = model.location == nil

         descriptionLabel.text = model.description
         descriptionLabel.isHidden = model.description == nil

         fadeIn(UIImage(named: model.imageName))
     }
 }
