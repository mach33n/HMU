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
  UNUserNotificationCenterDelegate {

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
          contactAPI.shared.sendAMessage(number: "\(String(describing: phoneNumber))")
        }
        break

      case "DECLINE_ACTION":
        print("Decline")
        break

      case "DELETE_ACTION":
//        //Add confirmation step
//        ContactList.deleteContact(number: "\(String(describing: phoneNumber))") { (load) in
//          if load {
//            //Successful deletion
//          }
//        }
        break

      default:
        break
      }
      // Always call the completion handler when done.
      completionHandler()
    }
}
