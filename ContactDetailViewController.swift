//
//  ContactDetailViewController.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-05-24.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {

  @IBOutlet weak var contactImage: UIImageView!
  @IBOutlet weak var contactNameLabel: UILabel!
  @IBOutlet weak var contactPhoneLabel: UILabel!
  @IBOutlet weak var contactEmailLabel: UILabel!
  @IBOutlet weak var contactAddressLabel: UILabel!


  var contactInfo: HCContact?

  @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()
    if let contact = self.contactInfo {
      contact.fetchImageIfNeeded()
      contactImage.image = contact.contactImage
      contactImage.layer.cornerRadius = contactImage.frame.height / 2
      contactNameLabel.text = "\(contact.givenName) \(contact.familyName)"
      contactPhoneLabel.text = contact.phoneNumber
      contactEmailLabel.text = contact.emailAddress
      contactAddressLabel.text = contact.address
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.onKeyboardAppear(notifcation:)),
                                           name: UIResponder.keyboardWillShowNotification,
                                           object: nil)

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.onKeyboardHide(notifcation:)),
                                           name: UIResponder.keyboardWillHideNotification,
                                           object: nil)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)

    NotificationCenter.default.removeObserver(self)
  }

  @objc func onKeyboardAppear(notifcation: NSNotification) {
    guard let userInfo = notifcation.userInfo, let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
      let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

    scrollViewBottomConstraint.constant = keyboardFrameValue.cgRectValue.size.height
    UIView.animate(withDuration: animationDuration, animations: {
      [weak self] in self?.view.layoutIfNeeded()
    })
  }

  @objc func onKeyboardHide(notifcation: NSNotification) {
    guard let userInfo = notifcation.userInfo,
      let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

    scrollViewBottomConstraint.constant = 0
    UIView.animate(withDuration: animationDuration, animations: {
      [weak self] in self?.view.layoutIfNeeded()
    })
  }

}
