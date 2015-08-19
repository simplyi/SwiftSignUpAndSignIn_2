//
//  SignUpViewController.swift
//  MyNewApp
//
//  Created by Sergey Kargopolov on 2015-06-05.
//  Copyright (c) 2015 Sergey Kargopolov. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var userEmailAddressTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userPasswordRepeatTextField: UITextField!
    @IBOutlet weak var userFirstNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        self.edgesForExtendedLayout = UIRectEdge()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectProfilePhotoButtonTapped(sender: AnyObject) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(myPickerController, animated: true, completion: nil)
        
        
    }
    
 

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        profilePhotoImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
 
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
 
    @IBAction func signUpButtonTapped(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        
        let userName = userEmailAddressTextField.text
        let userPassword = userPasswordTextField.text
        let userPasswordRepeat = userPasswordRepeatTextField.text
        let userFirstName = userFirstNameTextField.text
        let userLastName = userLastNameTextField.text
        
        if(userName!.isEmpty || userPassword!.isEmpty || userPasswordRepeat!.isEmpty || userFirstName!.isEmpty || userLastName!.isEmpty)
        {
        
            let myAlert = UIAlertController(title:"Alert", message:"All fields are required to fill in", preferredStyle:UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)
            
           return
        }
        
        if(userPassword != userPasswordRepeat)
        {
            let myAlert = UIAlertController(title:"Alert", message:"Passwords do not match. Please try again", preferredStyle:UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)
            
          return
        }
        
        
        let myUser:PFUser = PFUser()
        myUser.username = userName
        myUser.password = userPassword
        myUser.email = userName
        myUser.setObject(userFirstName!, forKey: "first_name")
        myUser.setObject(userLastName!, forKey: "last_name")
        
        
        let profileImageData = UIImageJPEGRepresentation(profilePhotoImageView.image!, 1)
        
        if(profileImageData != nil)
        {
             let profileImageFile = PFFile(data: profileImageData!)
             myUser.setObject(profileImageFile, forKey: "profile_picture")
        }
        
        
        // Show activity indicator
        let spiningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spiningActivity.labelText = "Sending"
        spiningActivity.detailsLabelText = "Please wait"
        
        
 
 
        myUser.signUpInBackgroundWithBlock { (success, error) -> Void in
           
            // Hide activity indicator
            spiningActivity.hide(true)
            
            var userMessage = "Registration is successful. Thank you!"
            
            if(!success)
            {
               //userMessage = "Could not register at this time please try again later."
                userMessage = error!.localizedDescription
            }
            
            
            let myAlert = UIAlertController(title:"Alert", message:userMessage, preferredStyle:UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){ action in
            
                if(success)
                {
                  self.dismissViewControllerAnimated(true, completion: nil)
                }
                
            }
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)
            
        }
 
        
        
    }
}
