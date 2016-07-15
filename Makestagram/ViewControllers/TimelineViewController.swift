//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Kalpana on 7/11/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit

//the property definition for photoTakingHelper
var photoTakingHelper: PhotoTakingHelper?

//create the property that will store the TimelineComponent object. two different types in the angled brackets: the type of object you are displaying (Post) and the class that will be the target of the TimelineComponent (that's the TimelineViewController in our case).


class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!
    
    //defining the properties necessary to implement the protocol
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self //we are setting the TimelineViewController to be the delegate of the tabBarController.

    }

    
    func takePhoto() {
        //we're creating an instance of PhotoTakingHelper. We're assigning that instance to the photoTakingHelper property.
        //As the view controller we pass self.tabBarController. The tab bar controller is the Root View Controller of our application - typically you want to present most popups directly on the Root View Controller. 
        //As a callback we pass a closure.

        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            let post = Post()
            // 1
            post.image.value = image!
            post.uploadPost()
        }
    }
    
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        // 1
        ParseHelper.timelineRequestForCurrentUser(range) { (result: [PFObject]?, error: NSError?) -> Void in
            // In the callback of the query we check whether or not we have received a result. If the result is nil we store an empty array in the posts variable
            
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            
            let posts = result as? [Post] ?? []
            // 3
            completionBlock(posts)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        timelineComponent.loadInitialIfRequired()
        
        }
}

extension TimelineViewController: UITabBarControllerDelegate {
    //controls the tab bar
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {//if the photoviewcontroller is clicked, then it calls 
            //takePhoto()
            takePhoto()
            return false//false is returned and the execution ends
        } else {//otherwise, it returns true and further processes are carried out
            return true
        }
    }

}


extension TimelineViewController: UITableViewDataSource {
    
    //Our Table View needs to have as many rows as we have posts stored in the posts property
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.timelineComponent.content.count
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = timelineComponent.content[indexPath.section]
        post.downloadImage()
        post.fetchLikes()
        cell.post = post
        
        return cell
    }
    
    

}

extension TimelineViewController: UITableViewDelegate {
        
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.section)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostSectionHeaderView
        
        let post = self.timelineComponent.content[section]
        headerCell.post = post
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
        
}
