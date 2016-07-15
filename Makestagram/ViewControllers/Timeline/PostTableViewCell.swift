//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Kalpana on 7/12/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {
   
    //making two disposable instance variables to help free up bindings
    var postDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    //connection to labels/buttons/images
    @IBOutlet var PostImageView: UIImageView!
    @IBOutlet var likesIconImageView: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var likesLabel: UILabel!
    @IBOutlet var moreButton: UIButton!

    //carries out actions for a button
    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
    }
    
    var post: Post? {
        didSet {
                
                postDisposable?.dispose()
                likeDisposable?.dispose()
            
                // The oldValue variable is available automatically in the didSet property observer. It provides us with a way to access the previous value of a property. We check if an oldValue exists and if that oldValue is different from the new post.
                if let oldValue = oldValue where oldValue != post {
                    // By setting oldValue.image.value to nil we are secretly fixing an issue that we haven't even discussed yet. Without this code in place, we are adding a new binding whenever a new post gets assigned to our PostTableViewCell. In most cases, where you create a binding, you should also have code that destroys that binding when it is no longer needed. In the case of the PostTableViewCell we don't need the binding anymore if the cell is displaying a new post. By setting oldValue.image.value to nil, we unsubscribe from future updates of the old post.
                    oldValue.image.value = nil
                }
                
                if let post = post {
                    postDisposable = post.image.bindTo(PostImageView.bnd_image)
                    
                    likeDisposable = post.likes.observe { (value: [PFUser]?) -> () in
                        if let value = value {
                            self.likesLabel.text = self.stringFromUserList(value)
                            self.likeButton.selected = value.contains(PFUser.currentUser()!)
                            self.likesIconImageView.hidden = (value.count == 0)
                        } else {
                            self.likesLabel.text = ""
                            self.likeButton.selected = false
                            self.likesIconImageView.hidden = true
                        }
                    }
                }
            }
        }
    
    func stringFromUserList(userList: [PFUser]) -> String {
        // we are mapping from PFUser objects to the usernames of these PFObjects.
        let usernameList = userList.map { user in user.username! }
        // We now use that array of strings to create one joint string. We can do that by using the joinWithSeparator method provided by Swift. The joinWithSeparator method can be called on any array of strings.
        let commaSeparatedUserList = usernameList.joinWithSeparator(", ")
        
        return commaSeparatedUserList
    }
    
}