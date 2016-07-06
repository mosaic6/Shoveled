//
//  LoginViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 9/21/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import UIKit
import Crashlytics
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnSignUp: ShoveledButton!
    @IBOutlet weak var btnGetStarted: UIButton!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var tfExistingUsername: UITextField!
    @IBOutlet weak var tfExistingPassword: UITextField!
    @IBOutlet weak var btnExistingLogin: ShoveledButton!
    
    let lblWelcome1 = UILabel()
    let lblWelcome2 = UILabel()
    let lblWelcome3 = UILabel()
    
    var currentStatusVC = CurrentStatusViewController()
    var ref:FIRDatabaseReference!
    var alert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        animateLaunchView()
    }
    
    override func viewDidAppear(animated: Bool) {
        if FIRAuth.auth()?.currentUser != nil {
            self.removeFromParentViewController()
        }
        ref = FIRDatabase.database().reference()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        lblWelcome1.center.x -= view.bounds.width
        lblWelcome2.center.x -= view.bounds.width
        lblWelcome3.center.x -= view.bounds.width
        tfExistingPassword.center.x -= view.bounds.width
        tfExistingUsername.center.x -= view.bounds.width
        tfEmail.hidden = true
        tfPassword.hidden = true
    }
    
    func configureView() {
        
        tfExistingUsername.text = "joshuatwalsh@gmail.com"
        tfExistingPassword.text = "way2cool"
        
        let formGroup = CAAnimationGroup()
        formGroup.duration = 0.5
        formGroup.fillMode = kCAFillModeBackwards
        formGroup.delegate = self
        formGroup.setValue("form", forKey: "name")
        formGroup.setValue(tfExistingUsername.layer, forKey: "layer")
        formGroup.setValue(tfExistingPassword.layer, forKey: "layer")
        formGroup.setValue(tfEmail.layer, forKey: "layer")
        formGroup.setValue(tfPassword.layer, forKey: "layer")
        formGroup.setValue(tfPassword.layer, forKey: "layer")
        
        tfExistingUsername.layer.addAnimation(formGroup, forKey: nil)
        tfExistingPassword.layer.addAnimation(formGroup, forKey: nil)
        
        let scaleDown = CABasicAnimation(keyPath: "transform.scale")
        scaleDown.fromValue = 3.5
        scaleDown.toValue = 1.0
        
        self.navigationController?.navigationBar.hidden = true  
        
        let darkBlur = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        blurView.frame = self.imgBackground.bounds
        self.imgBackground.insertSubview(blurView, atIndex: 0)
        
        lblWelcome1.textColor = UIColor.grayColor()
        lblWelcome1.text = "Snowed in?"
        lblWelcome1.font = UIFont(name: "Rajdhani-Bold", size: 28)
        lblWelcome1.numberOfLines = 5
        lblWelcome1.frame = CGRectMake(10, 0, self.view.frame.width - 20, 250)
        lblWelcome1.textAlignment = NSTextAlignment.Center
        self.view.addSubview(lblWelcome1)
        
        lblWelcome2.textColor = UIColor.grayColor()
        lblWelcome2.text = "Don't feel like shoveling?"
        lblWelcome2.font = UIFont(name: "Rajdhani-Bold", size: 28)
        lblWelcome2.numberOfLines = 5
        lblWelcome2.frame = CGRectMake(10, 0, self.view.frame.width - 20, 250)
        lblWelcome2.textAlignment = NSTextAlignment.Center
        self.view.addSubview(lblWelcome2)
        
        lblWelcome3.textColor = UIColor.grayColor()
        lblWelcome3.text = "Sign up and get shoveled out!"
        lblWelcome3.font = UIFont(name: "Rajdhani-Bold", size: 28)
        lblWelcome3.numberOfLines = 5
        lblWelcome3.frame = CGRectMake(10, 0, self.view.frame.width - 20, 250)
        lblWelcome3.textAlignment = NSTextAlignment.Center
        self.view.addSubview(lblWelcome3)
    }
    
    
    // MARK: - SIGN UP NEW USER
    func signUpUser() {
        
        guard let emailString = tfEmail.text?.stringByTrimmingCharactersInSet(NSCharacterSet .whitespaceCharacterSet()) else { return }
        guard let passwordString = tfPassword.text?.stringByTrimmingCharactersInSet(NSCharacterSet .whitespaceCharacterSet()) else { return }
        
        if emailString.characters.count == 0 || passwordString.characters.count == 0 {
            let alert = UIAlertController(title: "There was an error signing you up", message: "Please fill out all fields", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: .None))
            self.presentViewController(alert, animated: true, completion: .None)
        } else {
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
        
            FIRAuth.auth()?.createUserWithEmail(emailString, password: passwordString) { (user, error) in
                if let error = error {
                    self.alert.showMessagePrompt(error.localizedDescription)
                } else {
                    self.ref.child("users").child(user!.uid).setValue(["username": emailString])
                    self.removeFromParentViewController()
                }
            }
        }
    }
    
    // MARK: - ANIMATE FIELDS
    func animateLaunchView() {
        self.btnGetStarted.alpha = 0
        self.btnLogin.alpha = 0
        UIView.animateWithDuration(0.3, delay: 0.3, options: [.CurveEaseInOut], animations: {
            self.lblWelcome1.center.x += self.view.bounds.width
        }, completion: nil)
        UIView.animateWithDuration(0.3, delay: 2.0, options: [.CurveEaseInOut], animations: {
            self.lblWelcome1.center.x -= self.view.bounds.width
            self.lblWelcome2.center.x += self.view.bounds.width
        }, completion: nil)
        UIView.animateWithDuration(0.3, delay: 4.0, options: [.CurveEaseInOut], animations: {
            self.lblWelcome2.center.x -= self.view.bounds.width
            self.lblWelcome3.center.x += self.view.bounds.width
            self.btnGetStarted.hidden = false
            self.btnGetStarted.alpha = 1.0
            self.btnLogin.hidden = false
            self.btnLogin.alpha = 1.0
        }, completion: nil)
    }
    
    
    
    @IBAction func showLoginFom(sender: AnyObject) {
        UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut], animations: {
            self.hideSignUpForm()
            self.tfExistingUsername.hidden = false
            self.tfExistingPassword.hidden = false
            self.btnExistingLogin.hidden = false
            self.btnLogin.hidden = true
            self.btnGetStarted.hidden = false
        }, completion: nil)
    }
    
    @IBAction func showSignUpForm(sender: AnyObject) {
        UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut], animations: {
            self.lblWelcome3.center.x -= self.view.bounds.width
        }, completion: nil)
        UIView.animateWithDuration(0.9, delay: 2.0, options: [.CurveEaseInOut], animations: {
            self.tfEmail.hidden = false
            self.tfPassword.hidden = false
            self.btnSignUp.hidden = false
            self.btnGetStarted.hidden = true
        }, completion: nil)
    }
    @IBAction func signUpNewUser(sender: AnyObject) {
        signUpUser()
    }
    
    @IBAction func loginUser(sender: AnyObject) {
        showSpinner()
        guard let usernameString = tfExistingUsername.text?.stringByTrimmingCharactersInSet(NSCharacterSet .whitespaceCharacterSet()) else { return }
        guard let passwordString = tfExistingPassword.text?.stringByTrimmingCharactersInSet(NSCharacterSet .whitespaceCharacterSet()) else { return }
        
        if usernameString.characters.count == 0 || passwordString.characters.count == 0 {
            let alert = UIAlertController(title: "There was an error logging in", message: "Please fill out all fields", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: .None))
            self.presentViewController(alert, animated: true, completion: .None)
        } else {
            FIRAuth.auth()?.signInWithEmail(usernameString, password: passwordString, completion: { (user, error) in                
                if let error = error {
                    self.alert.showMessagePrompt(error.localizedDescription)
                } else if let user = user {
                    self.ref.child("users").child(user.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                        self.resignFirstResponder()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            })
        }
    }
    
    func hideSignUpForm() {
        self.lblWelcome3.hidden = true
        self.btnGetStarted.hidden = true
        self.tfEmail.hidden = true
        self.tfPassword.hidden = true
        self.btnSignUp.hidden = true
        self.tfExistingUsername.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTage=textField.tag+1;
        // Try to find next responder
        let nextResponder=textField.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        if let name = anim.valueForKey("name") as? String {
            if name == "form" {
                let layer = anim.valueForKey("layer") as? CALayer
                anim.setValue(nil, forKey: "layer")
                
                let pulse = CABasicAnimation(keyPath: "transform.scale")
                pulse.fromValue = 1.24
                pulse.toValue = 1.0
                pulse.duration = 0.20
                layer?.addAnimation(pulse, forKey: nil)
            }
        }
    }
}
