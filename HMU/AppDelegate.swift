//
//  AppDelegate.swift
//  HMU
//
//  Created by Cameron Bennett on 10/26/19.
//  Copyright © 2019 Cameron Bennett. All rights reserved.
//

import UIKit
import BackgroundTasks
import CoreData
import Contacts
import Firebase
import Messages

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    //unfinished
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    //unfinished
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    //unfinished
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    FirebaseApp.configure()
    contactAPI.shared.configureNotification()
   UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

    // Override point for customization after application launch.
    UINavigationBar.appearance().barTintColor = UIColor(red: 0, green: 0 / 255, blue: 205 / 255, alpha: 1)
    UITableViewCell.appearance().backgroundColor = UIColor.white
    UITableView.appearance().backgroundColor = UIColor.white
    UITableViewHeaderFooterView.appearance().tintColor = UIColor(red: 0, green: 0 / 255, blue: 205 / 255, alpha: 1)
    UITextField.appearance().backgroundColor = UIColor.white
    UITextView.appearance().backgroundColor = UIColor.white
    return true
  }

  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    contactAPI.shared.pullContact { (success) in
      print(success)
    }
  }

  // MARK: UISceneSession Lifecycle
  @available(iOS 13.0, *)
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  @available(iOS 13.0, *)
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    contactAPI.shared.saveContext()
  }
}
