//
//  LaunchViewController.swift
//  HMU
//
//  Created by Cameron Bennett on 4/19/20.
//  Copyright © 2020 Cameron Bennett. All rights reserved.
//

import UIKit
import Firebase

class LaunchViewController: UIViewController {
  
  var initialViewController: UIViewController?

  override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
      
        if (Auth.auth().currentUser != nil) {
          print(contactAPI.shared.loadContacts())
          self.performSegue(withIdentifier: "straightToDash", sender: nil)
        } else {
            self.performSegue(withIdentifier: "toLogin", sender: nil)
        }
        // Do any additional setup after loading the view.
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
