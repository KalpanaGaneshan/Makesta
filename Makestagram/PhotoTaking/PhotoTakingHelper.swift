//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by Kalpana on 7/11/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallback = UIImage? -> Void //Using the typealias keyword we can provide a function signature with a name. In this case we are saying that a function of type PhotoTakingHelperCallback has one parameter (a UIImage?) and returns Void. This means that any function that wants to be the callback of the PhotoTakingHelper needs to have exactly this signature.

class PhotoTakingHelper : NSObject {
    
    // View controller on which AlertViewController and UIImagePickerController are presented
    weak var viewController: UIViewController! //viewController, stores a weak reference to a UIViewController. As we discussed earlier, this reference is necessary because the PhotoTakingHelper needs a UIViewController on which it can present other view controllers. It is a weak reference because the PhotoTakingHelper does not own the referenced view controller.
    var callback: PhotoTakingHelperCallback //store the callback function
    var imagePickerController: UIImagePickerController?//provide a property to store a UIImagePickerController (which we will use a little bit later).
    
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback) {//The initializer of this class receives the view controller on which we will present other view controllers and the callback that we will call as soon as a user has picked an image.
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        showPhotoSourceSelection()
    }

    func showPhotoSourceSelection() {
        
        //set up the UIAlertController by providing it with a message and a preferredStyle. By choosing the .ActionSheet option we create a popup that gets displayed from the bottom edge of the screen.
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet)
        
        
        // After the initial set up, we add different UIAlertActions to the alert controller, each action will result in one additional button on the popup.
        
        // The first action is the default Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        //The second option allows the user to pick an image from the library. We create a UIAlertAction for the library and add it to the UIAlertController.
        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default) { (action) in
            self.showImagePickerController(.PhotoLibrary)
        }
        
        
        alertController.addAction(photoLibraryAction)

        
        // Only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .Default) { (action) in
                self.showImagePickerController(.Camera)//call showImagePickerController and pass either .PhotoLibrary or .Camera as argument - based on the user's choice.
            }
            
            //Here we present the alertController. As we discussed earlier, view controllers can only be presented from other view controllers. We use the reference that we've stored in the viewController property and call the presentViewController method on it.
            alertController.addAction(cameraAction)
        }
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }

    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        //this method creates a UIImagePickerController.
        imagePickerController = UIImagePickerController()
        
        //we set the sourceType of that controller. Depending on the sourceType the UIImagePickerController will activate the camera and display a photo taking overlay - or will show the user's photo library.
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self// sets up the delegate property of imagePickerController:
        
        //Our showImagePickerController method takes the sourceType as an argument and hands it on to the imagePickerController - that allows the caller of this method to specify whether the camera or the photo library should be used as an image source.
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)    }
}


//We implement two different delegate methods: One is called when an image is selected, the other is called when the cancel button is tapped.
extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //First we hide the image picker controller, then we call the callback and hand it the image that has been selected as an argument. 
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        
        callback(image)
    }
    
    //Within imagePickerControllerDidCancel we simply hide the image picker controller by calling dismissViewControllerAnimated on viewController.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}