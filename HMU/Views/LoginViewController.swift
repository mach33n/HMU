//
//  ViewController.swift
//  AMLoginSingup
//
//  Created by amir on 10/11/16.
//  Copyright © 2016 amirs.eu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import AwesomeContactPicker
import Contacts
import UserNotifications
import Messages
import MessageUI

enum AMLoginSignupViewMode {
  case login
  case signup
}

class LoginViewController: UIViewController {

  let animationDuration = 0.25
  var mode: AMLoginSignupViewMode = .signup

  //MARK: - background image constraints
  @IBOutlet weak var backImageLeftConstraint: NSLayoutConstraint!
  @IBOutlet weak var backImageBottomConstraint: NSLayoutConstraint!


  //MARK: - login views and constrains
  @IBOutlet weak var loginView: UIView!
  @IBOutlet weak var loginContentView: UIView!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var loginButtonVerticalCenterConstraint: NSLayoutConstraint!
  @IBOutlet weak var loginButtonTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var loginWidthConstraint: NSLayoutConstraint!


  //MARK: - signup views and constrains
  @IBOutlet weak var signupView: UIView!
  @IBOutlet weak var signupContentView: UIView!
  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var signupButtonVerticalCenterConstraint: NSLayoutConstraint!
  @IBOutlet weak var signupButtonTopConstraint: NSLayoutConstraint!


  //MARK: - logo and constrains
  @IBOutlet weak var logoView: UIView!
  @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var logoButtomInSingupConstraint: NSLayoutConstraint!
  @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!


  @IBOutlet weak var forgotPassTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var socialsView: UIView!


  //MARK: - input views
  @IBOutlet weak var loginEmailInputView: AMInputView!
  @IBOutlet weak var loginPasswordInputView: AMInputView!
  @IBOutlet weak var signupEmailInputView: AMInputView!
  @IBOutlet weak var signupPasswordInputView: AMInputView!
  @IBOutlet weak var signupPasswordConfirmInputView: AMInputView!


  //MARK: - controller
  override func viewDidLoad() {
    super.viewDidLoad()
    
    logoView.layer.masksToBounds = false
    logoView.layer.cornerRadius = logoView.frame.size.height / 2
    logoView.clipsToBounds = true

    // set view to login mode
    toggleViewMode(animated: true)

    //add keyboard notification
    NotificationCenter.default.addObserver(self, selector: #selector(keyboarFrameChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    view.accessibilityIdentifier = "logo"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if (Auth.auth().currentUser != nil) {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)

      let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeSlideViewController") as! HomeSlideViewController

      self.present(initialViewController, animated: true, completion: nil)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  //MARK: - button actions
  @IBAction func loginButtonTouchUpInside(_ sender: AnyObject) {
    if mode == .signup {
      toggleViewMode(animated: true)
    } else {
      if (loginEmailInputView.textFieldView.text != "" && loginPasswordInputView.textFieldView.text != "") {
        Auth.auth().signIn(withEmail: loginEmailInputView.textFieldView.text! + "@gmail.com", password: loginPasswordInputView.textFieldView.text!) { (result, error) in
          if((error) != nil) {
            print(error!.localizedDescription)
            return
          }
          User.name = self.loginEmailInputView.textFieldView.text!
          User.uid = Auth.auth().currentUser!.uid
          self.performSegue(withIdentifier: "toDash", sender: nil)
        }
      }
      //TODO: login by this data
      NSLog("Email:\(String(describing: loginEmailInputView.textFieldView.text)) Password:\(String(describing: loginPasswordInputView.textFieldView.text))")
    }
  }

  @IBAction func signupButtonTouchUpInside(_ sender: AnyObject) {
    if mode == .login {
      toggleViewMode(animated: true)
    } else {
      if (signupEmailInputView.textFieldView.text != "" && signupPasswordInputView.textFieldView.text != "" && signupPasswordInputView.textFieldView.text == signupPasswordConfirmInputView.textFieldView.text) {
        AwesomeContactSettings.nameLabelTextColor = UIColor.black
        AwesomeContactSettings.navBarBarTintColor = UIColor.white
        AwesomeContactSettings.searchTextFieldTextColor = UIColor.white
        AwesomeContactSettings.sectionIndexColor = UIColor.white
        AwesomeContactPicker.shared.openContacts(with: self, delegate: self)
      }
      //TODO: signup by this data
      NSLog("Email:\(String(describing: signupEmailInputView.textFieldView.text)) Password:\(String(describing: signupPasswordInputView.textFieldView.text)), PasswordConfirm:\(String(describing: signupPasswordConfirmInputView.textFieldView.text))")
    }
  }



  //MARK: - toggle view
  func toggleViewMode(animated: Bool) {

    // toggle mode
    mode = mode == .login ? .signup : .login


    // set constraints changes
    backImageLeftConstraint.constant = mode == .login ? 0 : -self.view.frame.size.width


    loginWidthConstraint.isActive = mode == .signup ? true : false
    logoCenterConstraint.constant = (mode == .login ? -1 : 1) * (loginWidthConstraint.multiplier * self.view.frame.size.width) / 2
    loginButtonVerticalCenterConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(mode == .login ? 300 : 900))
    signupButtonVerticalCenterConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(mode == .signup ? 300 : 900))


    //animate
    self.view.endEditing(true)

    UIView.animate(withDuration: animated ? animationDuration : 0) {

      //animate constraints
      self.view.layoutIfNeeded()

      //hide or show views
      self.loginContentView.alpha = self.mode == .login ? 1 : 0
      self.signupContentView.alpha = self.mode == .signup ? 1 : 0


      // rotate and scale login button
      let scaleLogin: CGFloat = self.mode == .login ? 1 : 0.4
      let rotateAngleLogin: CGFloat = self.mode == .login ? 0 : CGFloat(Double.pi / 2)

      var transformLogin = CGAffineTransform(scaleX: scaleLogin, y: scaleLogin)
      transformLogin = transformLogin.rotated(by: rotateAngleLogin)
      self.loginButton.transform = transformLogin


      // rotate and scale signup button
      let scaleSignup: CGFloat = self.mode == .signup ? 1 : 0.4
      let rotateAngleSignup: CGFloat = self.mode == .signup ? 0 : CGFloat(Double.pi / 2)

      var transformSignup = CGAffineTransform(scaleX: scaleSignup, y: scaleSignup)
      transformSignup = transformSignup.rotated(by: rotateAngleSignup)
      self.signupButton.transform = transformSignup
    }

  }

  //MARK: - Social Media Buttons

  @IBAction func facebookSignIn(_ sender: Any) {
    print("Facebook")
  }

  @IBAction func linkedInSignIn(_ sender: Any) {
    print("LinkedIn")
  }

  @IBAction func twitterSignIn(_ sender: Any) {
    print("Twitter")
  }

  //MARK: - keyboard
  @objc func keyboarFrameChange(notification: NSNotification) {

    let userInfo = notification.userInfo as! [String:AnyObject]

    // get top of keyboard in view
    guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
      //Handle error
      return
    }

    let topOfKetboard = keyboardFrame.cgRectValue.origin.y

    // get animation curve for animate view like keyboard animation
    var animationDuration: Double = 0.25
    var animationCurve: UIView.AnimationCurve = .easeOut
    if let animDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
      animationDuration = animDuration.doubleValue
    }

    if let animCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
      animationCurve = UIView.AnimationCurve.init(rawValue: animCurve.intValue)!
    }


    // check keyboard is showing
    let keyboardShow = topOfKetboard != self.view.frame.size.height


    //hide logo in little devices
    let hideLogo = self.view.frame.size.height < 667

    // set constraints
    backImageBottomConstraint.constant = self.view.frame.size.height - topOfKetboard

    logoTopConstraint.constant = keyboardShow ? (hideLogo ? 0 : 20) : 50
    logoHeightConstraint.constant = keyboardShow ? (hideLogo ? 0 : 40) : 60
    logoBottomConstraint.constant = keyboardShow ? 20 : 32
    logoButtomInSingupConstraint.constant = keyboardShow ? 20 : 32

    forgotPassTopConstraint.constant = keyboardShow ? 30 : 45

    loginButtonTopConstraint.constant = keyboardShow ? 25 : 30
    signupButtonTopConstraint.constant = keyboardShow ? 23 : 35

    loginButton.alpha = keyboardShow ? 1 : 0.7
    signupButton.alpha = keyboardShow ? 1 : 0.7



    // animate constraints changes
    UIView.beginAnimations(nil, context: nil)
    UIView.setAnimationDuration(animationDuration)
    UIView.setAnimationCurve(animationCurve)

    self.view.layoutIfNeeded()

    UIView.commitAnimations()

  }

  //MARK: - hide status bar in swift3

  override var prefersStatusBarHidden: Bool {
    return false
  }
}

extension LoginViewController: AwesomeContactPickerProtocol {
  
  func contactPicker(_ contactPicker: UIViewController, didSelectContactWithIdentifierKey identifierKey: String, completion: @escaping (Bool) -> ()) {
    //Don't forget to implement
    completion(true)
  }
  
  func contactPicker(_ contactPicker: UIViewController, didDeselectContactWithIdentifierKey identifierKey: String, completion: @escaping (Bool) -> ()) {
    //Don't forget to implement
    completion(true)
  }
  
  func contactPicker(_ contactPicker: UIViewController, didDismissWithType type: AwesomeContactPicker.DismissType, contacts: Set<String>?) {
    if (contacts?.count == 0) {
      let alert = UIAlertController(title: "You didn't add any contacts!", message: "Please sign up when you have contacts you would like to add.", preferredStyle: .actionSheet)

      self.present(alert, animated: true)
      return
    }
    switch type {
    case .cancel: break
      //Handle Cancel
    case .done:
      let keys = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
             CNContactEmailAddressesKey,
             CNContactPhoneNumbersKey,
             CNContactGivenNameKey,
             CNContactFamilyNameKey,
             CNContactPostalAddressesKey,
             CNContactImageDataAvailableKey,
             CNContactImageDataKey,
             CNContactNicknameKey] as [Any]
      do {
        for result in contacts! {
          let contact = try contactAPI.shared.contactStore.unifiedContact(withIdentifier: result, keysToFetch: keys as! [CNKeyDescriptor])
          contactAPI.shared.addContact(contact: HCContact(contact: contact))
        }
      } catch {
        print("unable to fetch contacts")
      }
      contactAPI.shared.loadContacts()
      self.performSegue(withIdentifier: "toDash", sender: nil)
    default:
      break
    }
    Auth.auth().createUser(withEmail: signupEmailInputView.textFieldView.text! + "@gmail.com", password: signupPasswordInputView.textFieldView.text!) { authResult, error in
      print(authResult)
      if((error) != nil) {
        print(error!.localizedDescription)
      } else {
        Auth.auth().signIn(withEmail: self.signupEmailInputView.textFieldView.text!, password: self.signupPasswordInputView.textFieldView.text!) { (result, error) in
            User.name = self.signupEmailInputView.textFieldView.text!
            User.uid = Auth.auth().currentUser!.uid
        }
      }
    }
  }
}
