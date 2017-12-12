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
import FirebaseDatabase
import Crashlytics

class LoginViewController: UIViewController {

    @IBOutlet weak var tfExistingUsername: UITextField!
    @IBOutlet weak var tfExistingPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var imgBackground: UIImageView!

    var ref: DatabaseReference?
    var alert: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboards))
        self.view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureView()
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.imgBackground.isHidden = true
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
            Auth.auth().signIn(withEmail: usernameString, password: passwordString, completion: { (user, error) in
                if let error = error {
                    self.hideActivityIndicator(self.view)
                    let alert = UIAlertController(title: "There was an error logging in", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: .none))
                    self.present(alert, animated: true, completion: .none)
                } else if let user = user {
                    self.ref?.child("users").child(user.uid).observeSingleEvent(of: .value, with: { _ in
                    })
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: userLocationNoticationKey), object: self)
                }
            })
        }
    }

    // Reset Password
    @IBAction func resetPassword(_ sender: AnyObject) {
        guard let usernameString = tfExistingUsername.text?.trimmingCharacters(in: CharacterSet.whitespaces) else { return }

        if usernameString == "" {
            let alert: UIAlertController = UIAlertController(title: "Whoops", message: "Please enter your email address and then press the forgot password button.", preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        } else {
            Auth.auth().sendPasswordReset(withEmail: usernameString) { error in
                if let error = error {
                    let alert: UIAlertController = UIAlertController(title: nil, message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                } else {
                    let alert: UIAlertController = UIAlertController(title: nil, message: "Your reset password link has been emailed to you.", preferredStyle: .alert)
                    let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                }
            }
        }
    }

    @objc func dismissKeyboards() {
        tfExistingUsername.resignFirstResponder()
        tfExistingPassword.resignFirstResponder()
    }

}
