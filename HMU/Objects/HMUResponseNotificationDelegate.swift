//
//  HMUResponseNotificationDelegate.swift
//  HMU
//
//  Created by Cameron Bennett on 11/26/19.
//  Copyright © 2019 Cameron Bennett. All rights reserved.
//

import Foundation
import UserNotifications
import UserNotificationsUI
import MessageUI
import Messages

class HMUResponseNotificationDelegate: NSObject,
  UNUserNotificationCenterDelegate, MFMessageComposeViewControllerDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

      // Get the meeting ID from the original notification.
      let userInfo = response.notification.request.content.userInfo
      let phoneNumber = userInfo["PHONE_NUMBER"]

      // Perform the task associated with the action.
      switch response.actionIdentifier {
      case "ACCEPT_ACTION":
        if !MFMessageComposeViewController.canSendText() {
          print("SMS services are not available")
        } else {
          // call method
          sendAMessage(number: "\(String(describing: phoneNumber))")
        }
        break

      case "DECLINE_ACTION":
        print("Decline")
        break

      case "DELETE_ACTION":
        //Add confirmation step
        ContactList.deleteContact(number: "\(String(describing: phoneNumber))") { (load) in
          if load {
            //Successful deletion
          }
        }
        break

      default:
        break
      }

      // Always call the completion handler when done.
      completionHandler()
    }

    func sendAMessage(number: String) {
      // message view controller
      let messageVC = MFMessageComposeViewController()
      messageVC.body = "Whats up! How ya been?"
      messageVC.recipients = [number]

      // set the delegate
      messageVC.messageComposeDelegate = self

      // present the message view controller
      if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
          topController = presentedViewController
          //topController.isModalInPresentation = true
          topController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
          topController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        }
        topController.present(messageVC, animated: true, completion: nil)
      }
    }

    // delegate implementation
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
      switch result {
      case .cancelled:
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
      case .failed:
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
      case .sent:
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
      default:
        break
      }
    }
}
