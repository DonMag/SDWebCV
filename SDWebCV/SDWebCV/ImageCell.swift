//
//  ImageCell.swift
//  SDWebCV
//
//  Created by Don Mag on 4/26/24.
//

import UIKit

class ImageCell: UICollectionViewCell {

	@IBOutlet var imageContentView: UIImageView!
	@IBOutlet var imgHeight: NSLayoutConstraint!
	
}

class MyImageCell: UICollectionViewCell {
	
	@IBOutlet var imageContentView: MyImageView!
	@IBOutlet var imgHeight: NSLayoutConstraint!
	
}

class MyTextCell: UICollectionViewCell {
	@IBOutlet var theLabel: UILabel!
	
	func delayedText(str: String) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
			self.theLabel.text = str
		})
	}
}
