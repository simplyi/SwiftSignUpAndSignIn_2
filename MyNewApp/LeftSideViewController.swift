//
//  LeftSideViewController.swift
//  MyNewApp
//
//  Created by Sergey Kargopolov on 2015-06-07.
//  Copyright (c) 2015 Sergey Kargopolov. All rights reserved.
//

import UIKit
import Parse

class LeftSideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    var menuItems:[String] = ["Main","About","Sign out"]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.view.layoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadUserDetails()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       return menuItems.count
    }
 
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let myCell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) 
        
       myCell.textLabel?.text = menuItems[indexPath.row]
        
        return myCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
       switch(indexPath.row)
       {
       case 0:
        // open main page
        
        let mainPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainPageViewController") as! MainPageViewController
        
        let mainPageNav = UINavigationController(rootViewController: mainPageViewController)
        
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.drawerContainer!.centerViewController = mainPageNav
        appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        
        
        break
       
       case 1:
        // open about page
        
        let aboutViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AboutViewController") as! AboutViewController
        
        let aboutPageNav = UINavigationController(rootViewController: aboutViewController)
        
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.drawerContainer!.centerViewController = aboutPageNav
        appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        break
        
        
       case 2:
        // perform sign out and take user to sign in page
        
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_name")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        
        let spiningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spiningActivity.labelText = "Sending"
        spiningActivity.detailsLabelText = "Please wait"
        
        
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            
            
            spiningActivity.hide(true)
            
            
            // Navigate to Protected page
            let mainStoryBoard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
            
            let signInPage:ViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
            
            let signInPageNav = UINavigationController(rootViewController:signInPage)
            
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = signInPageNav
            
            
        }

        
        
        break
        
       default:
        print("Option is not handled")
        
       }
        
    }

    @IBAction func editButtonTapped(sender: AnyObject) {
        
        let editProfile = self.storyboard?.instantiateViewControllerWithIdentifier("EditProfileViewController") as! EditProfileViewController
        editProfile.opener = self
        
        let editProfileNav = UINavigationController(rootViewController: editProfile)
        
        self.presentViewController(editProfileNav, animated: true, completion: nil)
    }
    
    func loadUserDetails()
    {
        if(PFUser.currentUser() == nil)
        {
            return
        }
        
        let userFirstName = PFUser.currentUser()?.objectForKey("first_name") as? String
        
        if userFirstName == nil
        {
           return
        }
        
        let userLastName = PFUser.currentUser()?.objectForKey("last_name") as! String
        
        userFullNameLabel.text = userFirstName! + " " + userLastName
        
        let profilePictureObject = PFUser.currentUser()?.objectForKey("profile_picture") as? PFFile
        
        if(profilePictureObject != nil)
        {
          profilePictureObject!.getDataInBackgroundWithBlock { (imageData:NSData?, error:NSError?) -> Void in
            
            if(imageData != nil)
            {
                self.userProfilePicture.image = UIImage(data: imageData!)
            }
            
         }
        }

    }
}
