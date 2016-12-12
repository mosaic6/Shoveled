//
//  SignUpViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 9/21/15.
//  Copyright © 2015 Lucky Penguin. All rights reserved.
//

import UIKit
import Crashlytics
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnSignUp: ShoveledButton!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    @IBOutlet weak var signupTitleLabel: UILabel!

    var currentStatusVC = CurrentStatusViewController()
    var ref: FIRDatabaseReference!
    var locationDelegate: LocationServicesDelegate?
    
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
        self.navigationController?.navigationBar.isHidden = true
    }

    func configureView() {
        self.navigationController?.navigationBar.isHidden = true

        let darkBlur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.frame = self.imgBackground.bounds
        self.imgBackground.insertSubview(blurView, at: 0)
    }

    // MARK: - SIGN UP NEW USER
    func signUpUser() {
        self.showActivityIndicatory(self.view)
        guard let emailString = tfEmail.text?.trimmingCharacters(in: CharacterSet.whitespaces) else { return }
        guard let passwordString = tfPassword.text?.trimmingCharacters(in: CharacterSet.whitespaces) else { return }

        if emailString.characters.count == 0 || passwordString.characters.count == 0 {
            let alert = UIAlertController(title: "There was an error signing you up", message: "Please fill out all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
            self.present(alert, animated: true, completion: .none)
            self.hideActivityIndicator(self.view)
        } else {
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView

            FIRAuth.auth()?.createUser(withEmail: emailString, password: passwordString) { (user, error) in
                if let error = error {
                    let alert = UIAlertController(title: "There was an error signing you up", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
                    self.present(alert, animated: true, completion: .none)
                    self.hideActivityIndicator(self.view)
                } else {
                    spinner.startAnimating()
                    self.ref.child("users").child(user!.uid).setValue(["username": emailString])
                    self.dismiss(animated: true, completion: nil)
                    let currentVC = CurrentStatusViewController()
                    self.present(currentVC, animated: true, completion: nil)
                    self.hideActivityIndicator(self.view)
                    self.locationDelegate?.checkLocationServices()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: userLocationNoticationKey), object: self)
                }
            }
        }
    }

    // MARK: - ANIMATE FIELDS
    func animateLaunchView() {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions(), animations: {
            self.welcomeTitleLabel.center.x += self.view.bounds.width
            self.signupTitleLabel.center.x += self.view.bounds.width
            self.tfEmail.center.x += self.view.bounds.width
            self.tfPassword.center.x += self.view.bounds.width
            self.btnSignUp.center.x += self.view.bounds.width
            self.btnLogin.center.x += self.view.bounds.width
        }, completion: nil)
    }

    @IBAction func signUpNewUser(_ sender: AnyObject) {
        signUpUser()
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
    }
}
