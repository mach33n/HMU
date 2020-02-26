//
//  ContactsCollectionViewLayout.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-05-08.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import UIKit

class ContactsCollectionViewLayout: UICollectionViewLayout {

  var itemSize = CGSize(width: 110, height: 90)
  var itemSpacing: CGFloat = 10

  private var numberOfItems = 0
  private var numOfRows = 0
  private var numColumns = 0

  //UICollectionViewLayoutAttributes is the type of object that is used to lay out collection view cells.
  var layoutAttributes = [UICollectionViewLayoutAttributes]()

  //these two simple calculations are enough to figure out the size of the collection view's contents.
  override var collectionViewContentSize: CGSize {
    let width = CGFloat(numColumns) * itemSize.width + CGFloat(numColumns - 1) * itemSpacing
    let height = CGFloat(numOfRows) * itemSize.height + CGFloat(numOfRows - 1) * itemSpacing

    return CGSize(width: width, height: height)
  }

  override func prepare() {
    guard let collectionView = collectionView else { return }
    let availableHeight = Int(collectionView.bounds.height + itemSpacing)
    let itemHeightForCalculation = Int(itemSize.height + itemSpacing)

    numberOfItems = collectionView.numberOfItems(inSection: 0)
    numOfRows = availableHeight / itemHeightForCalculation
    numColumns = Int(ceil(CGFloat(numberOfItems) / CGFloat(numOfRows)))
    layoutAttributes.removeAll()

    for itemIndex in 0..<numberOfItems {
      let row = itemIndex % numOfRows
      let column = itemIndex / numOfRows

      var xPos = column * Int(itemSize.width + itemSpacing)
      if row % 2 == 1 {
        xPos += Int(itemSize.width / 2)
      }

      let yPos = row * Int(itemSize.height + itemSpacing)

      let index = IndexPath(row: itemIndex, section: 0)
      let attributes = UICollectionViewLayoutAttributes(forCellWith: index)
      attributes.frame = CGRect(x: CGFloat(xPos), y: CGFloat(yPos), width: itemSize.width, height: itemSize.height)

      layoutAttributes.append(attributes)
    }
  }

  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let collectionView = collectionView else { return true }

    let availableHeight = newBounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
    let possibleRows = Int(availableHeight + itemSpacing) / Int(itemSize.height + itemSpacing)

    return possibleRows != numOfRows
  }

  /* This method is used by the collection view when it neesd the layout for multiple items at once. The most important take away from this method
       is that the collection view layout should be able to figure out which cells, or layout attributes, overlap with any given CGRECT inside
       of the collection view. */
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    /* To find out which attributes overlap the given CGRect, the filter method is used on the layoutAttributes that were calculated by prepare.
         The filter method loops over every item in the layoutAttributes array and calls the supplied closure, once for each attribute instance
         in the array. If the closure returns true, the attributes instance will be included in the output array; if it returns false
         then it will be omitted. */
    return layoutAttributes.filter { attributes in attributes.frame.intersects(rect) }
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return layoutAttributes[indexPath.row]
  }
}





















