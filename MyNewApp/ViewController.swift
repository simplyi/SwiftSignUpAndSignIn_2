//
//  ViewController.swift
//  MyNewApp
//
//  Created by Sergey Kargopolov on 2015-06-04.
//  Copyright (c) 2015 Sergey Kargopolov. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var userEmailAddressTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func signInButtonTapped(sender: AnyObject) {
        
        let userEmail = userEmailAddressTextField.text
        let userPassword = userPasswordTextField.text
        
        if(userEmail!.isEmpty || userPassword!.isEmpty)
        {
          return
        }
        
        
        let spiningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spiningActivity.labelText = "Sending"
        spiningActivity.detailsLabelText = "Please wait"
        //spiningActivity.userInteractionEnabled = false
        
        
        PFUser.logInWithUsernameInBackground(userEmail!, password: userPassword!) { (user:PFUser?, error:NSError?) -> Void in
            
           MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    
            
            var userMessage = "Welcome!"
            
            if(user != nil)
            {
                
                // Remember the sign in state
                let userName:String? = user?.username
                
                NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "user_name")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                // Navigate to Protected page
               
                let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                 appDelegate.buildUserInterface()
                
              
                
            } else {
                
                userMessage = error!.localizedDescription
                let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        
            
        }
        
        
    }
    
    @IBAction func facebookButtonTapped(sender: AnyObject) {
        
        
     // Create Permissions array
        let permissions = ["public_profile","email","user_friends"]
        
        // Login to Facebook with Permissions
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user:PFUser?, error:NSError?) -> Void in
   
            // If error, display message
            if(error != nil)
            {
                dispatch_async(dispatch_get_main_queue()) {
                    
                
                    let userMessage = error!.localizedDescription
                    let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    
                    myAlert.addAction(okAction)
                    
                    self.presentViewController(myAlert, animated: true, completion: nil)
                    return
                } // end of async
            }
            
            
            // Load facebook user details like user First name, Last name and email address
            self.loadFacebookUserDetails()
            
       })
        
    }
    
    func loadFacebookUserDetails()
    {
        
        // Show activity indicator
        let spiningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spiningActivity.labelText = "Loading"
        spiningActivity.detailsLabelText = "Please wait"
        
        
        // Define fields we would like to read from Facebook User object
        let requestParameters = ["fields": "id, email, first_name, last_name, name"]
        
        // Send Facebook Graph API Request for /me
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        userDetails.startWithCompletionHandler({
            (connection, result, error: NSError!) -> Void in
          
            
            
            if error != nil {
                
              // Display error message
                spiningActivity.hide(true)
                
                let userMessage = error!.localizedDescription
                let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.presentViewController(myAlert, animated: true, completion: nil)
                
                
                PFUser.logOut()

                return
            }
            
            
            // Extract user fields
            let userId:String = result["id"] as! String
            let userEmail:String? = result["email"] as? String
            let userFirstName:String?  = result["first_name"] as? String
            let userLastName:String? = result["last_name"] as? String
            
            
            
            // Get Facebook profile picture
            let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
            
            let profilePictureUrl = NSURL(string: userProfile)
            
            let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
            
            
            // Prepare PFUser object
            if(profilePictureData != nil)
            {
                let profileFileObject = PFFile(data:profilePictureData!)
                PFUser.currentUser()?.setObject(profileFileObject, forKey: "profile_picture")
            }
            
            PFUser.currentUser()?.setObject(userFirstName!, forKey: "first_name")
            PFUser.currentUser()?.setObject(userLastName!, forKey: "last_name")
            
            
            
            if let userEmail = userEmail
            {
                PFUser.currentUser()?.email = userEmail
                PFUser.currentUser()?.username = userEmail
            }
            
            
            
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) -> Void in
            
                spiningActivity.hide(true)
                
                if(error != nil)
                {
                    let userMessage = error!.localizedDescription
                    let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    
                    myAlert.addAction(okAction)
                    
                    self.presentViewController(myAlert, animated: true, completion: nil)
                    
                    
                    PFUser.logOut()
                    return

                
                }
                
                
                if(success)
                {
                    if !userId.isEmpty
                    {
                        NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "user_name")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.buildUserInterface()
                        }
                        
                    }
                    
                }
                
            })
 
            
         })
    
    }
    
    
    @IBAction func twitterButtonTapped(sender: AnyObject) {
       
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    // process user object
                    self.processTwitterUser()
                } else {
                    // process user object
                    self.processTwitterUser()
                }
            } else {
                print("Uh oh. The user cancelled the Twitter login.")
            }
        }

    }
    
    func processTwitterUser()
    {
        // Show activity indicator
        let spiningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spiningActivity.labelText = "Loading"
        spiningActivity.detailsLabelText = "Please wait"
        
        let pfTwitter = PFTwitterUtils.twitter()
        
        let twitterUsername =  pfTwitter?.screenName
        
        var userDetailsUrl:String = "https://api.twitter.com/1.1/users/show.json?screen_name="
        userDetailsUrl = userDetailsUrl + twitterUsername!

        let myUrl = NSURL(string: userDetailsUrl);
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "GET";
        
        pfTwitter!.signRequest(request);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                spiningActivity.hide(true)
                
                let userMessage = error!.localizedDescription
                let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.presentViewController(myAlert, animated: true, completion: nil)
                
                PFUser.logOut()
                return
                
            }
            
            do {
            
       
             let json =  try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                
                if let parseJSON = json
                {
                    // Extract profile image
                    if let profileImageUrl = parseJSON["profile_image_url"] as? String
                    {
                        let profilePictureUrl = NSURL(string: profileImageUrl)
                        
                        let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                        
                        
                        // Prepare PFUser object
                        if(profilePictureData != nil)
                        {
                            let profileFileObject = PFFile(data:profilePictureData!)
                            PFUser.currentUser()?.setObject(profileFileObject, forKey: "profile_picture")
                        }
                        
                        PFUser.currentUser()?.username = twitterUsername
                        PFUser.currentUser()?.setObject(twitterUsername!, forKey: "first_name")
                        PFUser.currentUser()?.setObject(" ", forKey: "last_name")
                        
                        PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) -> Void in
                       
                            if(error != nil)
                            {
                                spiningActivity.hide(true)
                                
                                //Display error message
                                let userMessage = error!.localizedDescription
                                let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
                                
                                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                                
                                myAlert.addAction(okAction)
                                
                                self.presentViewController(myAlert, animated: true, completion: nil)
                                
                                
                                PFUser.logOut()
                                
                                return
                            }
                            
                            
                            spiningActivity.hide(true)
                            NSUserDefaults.standardUserDefaults().setObject(twitterUsername, forKey: "user_name")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.buildUserInterface()
                            }
                            
                            
                        })
                        
                        
                    }
                }
                
            } catch {
               print(error)
            }
            
        }
        
        task.resume()
        
    }
    
}

