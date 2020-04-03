//
//  NotificationAcceptViewController.swift
//  HMU
//
//  Created by Cameron Bennett on 3/21/20.
//  Copyright © 2020 Cameron Bennett. All rights reserved.
//

import UIKit

class NotificationAcceptViewController: UIViewController {

  @IBOutlet weak var enableAccess: UIButton!
  
  override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
    }
    
  @IBAction func enableNotifAccess(_ sender: Any) {
    contactAPI.shared.configureNotification()
    
  }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
