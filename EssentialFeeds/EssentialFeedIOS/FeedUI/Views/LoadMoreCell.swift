//
//  LoadMoreCell.swift
//  EssentialFeedIOS
//
//  Created by TUSHAR SHARMA on 03/10/23.
//

import UIKit

public class LoadMoreCell:UITableViewCell{
    private lazy var indicator:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        contentView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
        ])
        return spinner
    }()
    
    public var isLoading:Bool{
        get{
            indicator.isAnimating
        }
        set{
            if newValue{
                indicator.startAnimating()
            }else{
                indicator.stopAnimating()
            }
        }
    }
}

