//
//  ContactCollectionViewCell.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-05-08.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit

class ContactCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var contactImage: UIImageView!

  //Function to fix the image issue
  override func prepareForReuse() {
    super.prepareForReuse()
  }

  /* awakeFromNib method is called the very first time this cell is created; you can use this method to do some
     inital setup that's requred to be executed only once for your cell */
  override func awakeFromNib() {
    super.awakeFromNib()
    //remeber that every view has a layer
    contactImage.layer.cornerRadius = contactImage.frame.height / 2 - 5
  }

  /* Used to customize your cell when the user taps on it. Example is change the background color or text color
     or even perform an animation.
     override func setSelected(_ selected: Bool, animated: Bool) {
     super.setSelected(selected, animated: animated)
     
     // Configure the view for the selected state
     } */

}
