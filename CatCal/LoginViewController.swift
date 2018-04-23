//
//  LoginViewController.swift
//  
//
//  Created by Michael on 4/16/18.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

/**
 A View Controller for handling pre-app functionality, namely logging in and signing up
 */
class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    // Google API related vars
    private let scopes = [kGTLRAuthScopeCalendar] /* If modifying these scopes, delete your previously saved credentials by resetting the iOS simulator or uninstalling the app. */
    static let service = GTLRCalendarService() /* There can only be one signed-in instance of the service, hence the static */
    let signInButton = GIDSignInButton()
    
    let logo = UIImageView(image: #imageLiteral(resourceName: "logo"))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply theme
        self.view.backgroundColor = bgColor
        
        // Configure Google Sign-in
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Position the sign-in button
        /// (at the bottom of the screen?)
        /// signInButton.frame = CGRect(x: (collectionView!.bounds.width - signInButton.frame.width) / 2, y: collectionView!.bounds.height - (signInButton.frame.height + navHeight), width: signInButton.frame.width, height: signInButton.frame.height)
        signInButton.frame = CGRect(x: (self.view.bounds.width - signInButton.frame.width) / 2, y: self.view.bounds.height / 2, width: signInButton.frame.width, height: signInButton.frame.height)
        
        // Position the logo
        logo.frame = CGRect(x: (self.view.bounds.width / 2) - 128, y: (self.view!.bounds.height / 2) - 256, width: 256, height: 256)
        
        // Add the UI elements to the current main view
        self.view.addSubview(signInButton)
        self.view.addSubview(logo)

    }
    
    /**
     *Silently* signs the user in to Google upon opening the app, if possible.
     
     - Remark: User has to already be signed into Google (which will most likely happen the first time they opened the app). Otherwise, the **Sign In** button will show up and the user will have to sign in.
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            log.error("Failed to log in")
            DailyViewController.generalErrorTitle = "Authentication Error"
            DailyViewController.generalErrorMessage = error.localizedDescription
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: alertKey), object: nil)
            LoginViewController.service.authorizer = nil
        } else {
            LoginViewController.service.authorizer = user.authentication.fetcherAuthorizer()
            log.debug("Logged in successfully")
            let tabController = self.storyboard!.instantiateViewController(withIdentifier: "Main") as! CalendarViewController
            tabController.selectedIndex = 0
            self.present(tabController, animated: true, completion: nil)
        }
    }

}
