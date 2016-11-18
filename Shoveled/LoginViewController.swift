//
//  LoginViewController
//  Shoveled
//
//  Created by Joshua Walsh on 11/18/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Crashlytics

class LoginViewController: UIViewController {
    
    @IBOutlet weak var tfExistingUsername: UITextField!
    @IBOutlet weak var tfExistingPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var imgBackground: UIImageView!
    
    var currentStatusVC = CurrentStatusViewController()
    var ref: FIRDatabaseReference?
    var alert: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboards))
        self.view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func configureView() {
        let darkBlur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.frame = self.imgBackground.bounds
        self.imgBackground.insertSubview(blurView, at: 0)
    }
    
    @IBAction func loginUser(_ sender: AnyObject) {
        self.dismissKeyboards()
        self.showActivityIndicatory(self.view)        
        guard let usernameString = tfExistingUsername.text?.trimmingCharacters(in: CharacterSet.whitespaces) else { return }
        guard let passwordString = tfExistingPassword.text?.trimmingCharacters(in: CharacterSet.whitespaces) else { return }
        
        if usernameString.characters.count == 0 || passwordString.characters.count == 0 {
            let alert = UIAlertController(title: "There was an error logging in", message: "Please fill out all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
            self.present(alert, animated: true, completion: .none)
        } else {
            FIRAuth.auth()?.signIn(withEmail: usernameString, password: passwordString, completion: { (user, error) in
                if let error = error {
                    self.hideActivityIndicator(self.view)
                    let alert = UIAlertController(title: "There was an error logging in", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
                    self.present(alert, animated: true, completion: .none)
                } else if let user = user {
                    self.ref?.child("users").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
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
    
    func dismissKeyboards() {
        tfExistingUsername.resignFirstResponder()
        tfExistingPassword.resignFirstResponder()
    }

}
