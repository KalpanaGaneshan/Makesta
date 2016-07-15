//
//  Post.swift
//  Makestagram
//
//  Created by Kalpana on 7/11/16.
//  Copyright © 2016 Make School. All rights reserved.
//



import Foundation
import Parse
import Bond
import ConvenienceKit


class Post : PFObject, PFSubclassing { //To create a custom Parse class you need to inherit from PFObject and implement the PFSubclassing protocol
    
    static var imageCache: NSCacheSwift<String, UIImage>! //the first is the type of the keys we want to store in the cache, the second is the type of the values. We want to store image files and access them through their filename so we choose <String, UIImage>.
    
    var image: Observable<UIImage?> = Observable(nil)//add an image property
    var photoUploadTask: UIBackgroundTaskIdentifier?//Add a photoUploadTask property to the Post class:
    var likes: Observable<[PFUser]?> = Observable(nil) //add a likes property
    
    //define each property that you want to access on this Parse class: the user and the imageFile of a post. That will allow you to change the code into code that uses Swift properties: post.imageFile = imageFile.
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    
    //MARK: PFSubclassing Protocol
    
    // 3
    static func parseClassName() -> String {//By implementing the parseClassName static function, you create a connection between the Parse class and your Swift class.
        return "Post"
    }
    
    // 4
    override init () {
        super.init()
    }
    
    
    func uploadPost() {
        
        if let image = image.value {
            
            //guard is just like optional binding in that it's used to unwrap optionals.
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            user = PFUser.currentUser()//allows us to access the user that's logged in
            self.imageFile = imageFile//We assign imageFile to self.imageFile.
            
            //First we create a background task. When a background task gets created iOS generates a unique ID and returns it. We store that unique id in the photoUploadTask property.
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            // we save the post and imageFile by calling saveInBackgroundWithBlock()
                saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    
                    if let error = error {
                        ErrorHandling.defaultErrorHandler(error)
                    }
                    
            //Within the completion handler of saveInBackgroundWithBlock() we inform iOS that our background task is completed. This block gets called as soon as the image upload is finished. 
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
    
    func downloadImage() {
        // We attempt to assign a value to image.value directly from the cache, using self.imageFile.name as key. If this assignment is successful the entire download block will be skipped.
        image.value = Post.imageCache[self.imageFile!.name]
        
        // If we didn't have the image cached, we proceed as usual. Then, when the image is downloaded, we add it to the cache.
        if (image.value == nil) {
            
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
                
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    self.image.value = image
                    // 2
                    Post.imageCache[self.imageFile!.name] = image
                }
            }
        }
    }
    
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
            // create an empty cache
            Post.imageCache = NSCacheSwift<String, UIImage>()
        }
    }
    
    func fetchLikes() {
        
        if (likes.value != nil) { // we are checking whether likes.value already has stored a value
            return
        }
        
        //We fetch the likes for the current Post using the ParseHelper likesForPost method that we created earlier
        ParseHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in
            
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            
            // We are removing all likes that belong to users that no longer exist in our Makestagram app (because their account has been deleted).
            let validLikes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            // replacing the likes in the array with the users that are associated with the like.
            self.likes.value = validLikes?.map { like in
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    
    func doesUserLikePost(user: PFUser) -> Bool{
        if let likes = likes.value {
            return likes.contains(user) //contains method simply returns whether or not the object is stored inside of the array.
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if post is liked, unlike it now
            likes.value = likes.value?.filter { $0 != user }//removing the user from the local cache stored in the likes property, then by syncing the change with Parse.
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this post is not liked yet, like it now
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
}