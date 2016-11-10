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

class LoginViewController: UIViewController {

    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnSignUp: ShoveledButton!
    @IBOutlet weak var btnGetStarted: UIButton!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var tfExistingUsername: UITextField!
    @IBOutlet weak var tfExistingPassword: UITextField!
    @IBOutlet weak var btnExistingLogin: ShoveledButton!
    @IBOutlet weak var btnForgotPassword: UIButton!

    let lblWelcome1 = UILabel()
    let lblWelcome2 = UILabel()
    let lblWelcome3 = UILabel()

    var currentStatusVC = CurrentStatusViewController()
    var ref: FIRDatabaseReference!
    var alert: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        animateLaunchView()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboards))
        self.view.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser != nil {
            self.removeFromParentViewController()
        }
        ref = FIRDatabase.database().reference()
    }

    override func viewWillAppear(_ animated: Bool) {
        lblWelcome1.center.x -= view.bounds.width
        lblWelcome2.center.x -= view.bounds.width
        lblWelcome3.center.x -= view.bounds.width
        tfExistingPassword.center.x -= view.bounds.width
        tfExistingUsername.center.x -= view.bounds.width
        tfEmail.isHidden = true
        tfPassword.isHidden = true
    }

    func configureView() {
        let formGroup = CAAnimationGroup()
        formGroup.duration = 0.5
        formGroup.fillMode = kCAFillModeBackwards
        formGroup.setValue("form", forKey: "name")
        formGroup.setValue(tfExistingUsername.layer, forKey: "layer")
        formGroup.setValue(tfExistingPassword.layer, forKey: "layer")
        formGroup.setValue(tfEmail.layer, forKey: "layer")
        formGroup.setValue(tfPassword.layer, forKey: "layer")
        formGroup.setValue(tfPassword.layer, forKey: "layer")

        tfExistingUsername.layer.add(formGroup, forKey: nil)
        tfExistingPassword.layer.add(formGroup, forKey: nil)

        let scaleDown = CABasicAnimation(keyPath: "transform.scale")
        scaleDown.fromValue = 3.5
        scaleDown.toValue = 1.0

        self.navigationController?.navigationBar.isHidden = true

        let darkBlur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.frame = self.imgBackground.bounds
        self.imgBackground.insertSubview(blurView, at: 0)

        lblWelcome1.textColor = UIColor.gray
        lblWelcome1.text = "Snowed in?"
        lblWelcome1.font = UIFont(name: "Rajdhani-Bold", size: 28)
        lblWelcome1.numberOfLines = 5
        lblWelcome1.frame = CGRect(x: 10, y: 0, width: self.view.frame.width - 20, height: 250)
        lblWelcome1.textAlignment = NSTextAlignment.center
        self.view.addSubview(lblWelcome1)

        lblWelcome2.textColor = UIColor.gray
        lblWelcome2.text = "Don't feel like shoveling?"
        lblWelcome2.font = UIFont(name: "Rajdhani-Bold", size: 28)
        lblWelcome2.numberOfLines = 5
        lblWelcome2.frame = CGRect(x: 10, y: 0, width: self.view.frame.width - 20, height: 250)
        lblWelcome2.textAlignment = NSTextAlignment.center
        self.view.addSubview(lblWelcome2)

        lblWelcome3.textColor = UIColor.gray
        lblWelcome3.text = "Sign up and get shoveled out!"
        lblWelcome3.font = UIFont(name: "Rajdhani-Bold", size: 28)
        lblWelcome3.numberOfLines = 5
        lblWelcome3.frame = CGRect(x: 10, y: 0, width: self.view.frame.width - 20, height: 250)
        lblWelcome3.textAlignment = NSTextAlignment.center
        self.view.addSubview(lblWelcome3)
    }

    // MARK: - SIGN UP NEW USER
    func signUpUser() {
        guard let emailString = tfEmail.text?.trimmingCharacters(in: CharacterSet.whitespaces) else { return }
        guard let passwordString = tfPassword.text?.trimmingCharacters(in: CharacterSet.whitespaces) else { return }

        if emailString.characters.count == 0 || passwordString.characters.count == 0 {
            let alert = UIAlertController(title: "There was an error signing you up", message: "Please fill out all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
            self.present(alert, animated: true, completion: .none)
        } else {
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
            spinner.startAnimating()

            FIRAuth.auth()?.createUser(withEmail: emailString, password: passwordString) { (user, error) in
                if let error = error {
                    let alert = UIAlertController(title: "There was an error signing you up", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
                    self.present(alert, animated: true, completion: .none)
                } else {
                    self.ref.child("users").child(user!.uid).setValue(["username": emailString])
                    self.dismiss(animated: true, completion: nil)
                    let currentVC = CurrentStatusViewController()
                    self.present(currentVC, animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: - ANIMATE FIELDS
    func animateLaunchView() {
        self.btnGetStarted.alpha = 0
        self.btnLogin.alpha = 0
        self.btnForgotPassword.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.3, options: UIViewAnimationOptions(), animations: {
            self.lblWelcome1.center.x += self.view.bounds.width
        }, completion: nil)
        UIView.animate(withDuration: 0.3, delay: 2.0, options: UIViewAnimationOptions(), animations: {
            self.lblWelcome1.center.x -= self.view.bounds.width
            self.lblWelcome2.center.x += self.view.bounds.width
        }, completion: nil)
        UIView.animate(withDuration: 0.3, delay: 4.0, options: UIViewAnimationOptions(), animations: {
            self.lblWelcome2.center.x -= self.view.bounds.width
            self.lblWelcome3.center.x += self.view.bounds.width
            self.btnGetStarted.isHidden = false
            self.btnGetStarted.alpha = 1.0
            self.btnLogin.isHidden = false
            self.btnLogin.alpha = 1.0
            self.btnForgotPassword.isHidden = true
        }, completion: nil)
    }

    // MARK: LOGIN AND SIGNUP METHODS
    @IBAction func showLoginFom(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.hideSignUpForm()
            self.tfExistingUsername.isHidden = false
            self.tfExistingPassword.isHidden = false
            self.btnExistingLogin.isHidden = false
            self.btnLogin.isHidden = true
            self.btnGetStarted.isHidden = false
            self.btnForgotPassword.isHidden = false
            self.btnSignUp.isHidden = true
            self.btnGetStarted.isHidden = true
            self.btnForgotPassword.alpha = 1.0
        }, completion: nil)
    }

    @IBAction func showSignUpForm(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.lblWelcome3.center.x -= self.view.bounds.width
        }, completion: nil)
        UIView.animate(withDuration: 0.9, delay: 2.0, options: UIViewAnimationOptions(), animations: {
            self.tfEmail.isHidden = false
            self.tfPassword.isHidden = false
            self.btnSignUp.isHidden = false
            self.btnGetStarted.isHidden = true
        }, completion: nil)
    }

    @IBAction func signUpNewUser(_ sender: AnyObject) {
        signUpUser()
    }

    @IBAction func loginUser(_ sender: AnyObject) {
        showSpinner(.whiteLarge)
        self.resignFirstResponder()
        guard let usernameString = tfExistingUsername.text?.trimmingCharacters(in: CharacterSet.whitespaces) else { return }
        guard let passwordString = tfExistingPassword.text?.trimmingCharacters(in: CharacterSet.whitespaces) else { return }

        if usernameString.characters.count == 0 || passwordString.characters.count == 0 {
            let alert = UIAlertController(title: "There was an error logging in", message: "Please fill out all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
            self.present(alert, animated: true, completion: .none)
        } else {
            FIRAuth.auth()?.signIn(withEmail: usernameString, password: passwordString, completion: { (user, error) in
                if let error = error {
                    let alert = UIAlertController(title: "There was an error logging in", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
                    self.present(alert, animated: true, completion: .none)
                } else if let user = user {
                    self.ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
                    })
                    self.dismiss(animated: true, completion: nil)
                    let currentVC = CurrentStatusViewController()
                    self.present(currentVC, animated: true, completion: nil)
                }
            })
        }
    }

    // Reset Password
    @IBAction func resetPassword(_ sender: AnyObject) {
        guard let usernameString = tfExistingUsername.text?.trimmingCharacters(in: CharacterSet.whitespaces) else { return }

        FIRAuth.auth()?.sendPasswordReset(withEmail: usernameString) { error in
            if let error = error {
                let alert: UIAlertController = UIAlertController(title: nil, message: "\(error.localizedDescription)", preferredStyle: .alert)
                let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: { _ in })
            } else {
                let alert: UIAlertController = UIAlertController(title: nil, message: "Your reset password link has been emailed to you.", preferredStyle: .alert)
                let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: { _ in })
            }
        }
    }

    func hideSignUpForm() {
        self.lblWelcome3.isHidden = true
        self.btnGetStarted.isHidden = true
        self.tfEmail.isHidden = true
        self.tfPassword.isHidden = true
        self.btnSignUp.isHidden = true
        self.tfExistingUsername.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTage = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTage) as UIResponder!

        if (nextResponder != nil) {
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }

        return false // We do not want UITextField to insert line-breaks.
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

        if let name = anim.value(forKey: "name") as? String {
            if name == "form" {
                let layer = anim.value(forKey: "layer") as? CALayer
                anim.setValue(nil, forKey: "layer")

                let pulse = CABasicAnimation(keyPath: "transform.scale")
                pulse.fromValue = 1.24
                pulse.toValue = 1.0
                pulse.duration = 0.20
                layer?.add(pulse, forKey: nil)
            }
        }
    }

    func dismissKeyboards() {
        tfEmail.resignFirstResponder()
        tfPassword.resignFirstResponder()
        tfExistingUsername.resignFirstResponder()
        tfExistingPassword.resignFirstResponder()
    }
}
