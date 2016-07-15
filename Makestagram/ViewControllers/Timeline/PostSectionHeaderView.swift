//
//  PostSectionHeaderView.swift
//  Makestagram
//
//  Created by Kalpana on 7/14/16.
//  Copyright © 2016 Make School. All rights reserved.
//
import UIKit

class PostSectionHeaderView: UITableViewCell {
    

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var post: Post? {
        didSet {
            if let post = post {
                usernameLabel.text = post.user?.username
                // 1
                timeLabel.text = post.createdAt?.shortTimeAgoSinceDate(NSDate()) ?? ""
            }
        }
    }
}