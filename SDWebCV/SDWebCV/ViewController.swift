//
//  ViewController.swift
//  SDWebCV
//
//  Created by Don Mag on 4/26/24.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
	enum Section {
		case main
	}
	
	// we will use these sizes to configure URLs to get
	//	sample images to download
	// we'll load the Google image as the first image
	let testImageSizes: [CGSize] = [
		.zero,
		.init(width: 400, height: 100),
		.init(width: 500, height: 300),
		.init(width: 300, height: 200),
		.init(width: 400, height: 150),
		.init(width: 400, height: 200),
		.init(width: 300, height: 100),
		.init(width: 500, height: 100),
		.init(width: 500, height: 200),
	]
	
	@IBOutlet weak var collectionView: UICollectionView!

	var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		self.configDataSource()
		self.configLayout()
	}
	
	
	func configDataSource() {
		let imageCellReg = UICollectionView.CellRegistration<ImageCell,Int>(cellNib: UINib(nibName: "ImageCell", bundle: nil)) { cell, indexPath, itemIdentifier in
			
			// alternate cell background colors
			cell.contentView.backgroundColor = indexPath.item % 2 == 0 ? .green : .cyan
			
			// format the URL for the test image size,
			//	e.g. "https://dummyimage.com/300x200.png"
			let thisData = self.testImageSizes[indexPath.item]
			
			var urlStr: String
			if thisData.width == 0 {
				urlStr = "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
			} else {
				urlStr = "https://dummyimage.com/\(Int(thisData.width))x\(Int(thisData.height)).png"
			}
			
			cell.imageContentView.sd_setImage (
				with: URL(string: urlStr),
				placeholderImage: UIImage(named: "somePlaceholder"),
				options: SDWebImageOptions(rawValue: 0),
				completed: { [weak self] image, error, cacheType, imageURL in
					guard let self = self,
						  let img = image
					else { return }
					
					// calculate proportional height
					let iw = cell.imageContentView.frame.width
					let ih = (img.size.height / img.size.width) * iw
					
					// update the height contraint in the cell
					cell.imgHeight.constant = ih

					// tell the collection view to re-layout the cells
					self.collectionView.collectionViewLayout.invalidateLayout()
				}
			)
		}
		self.dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
			return self.collectionView.dequeueConfiguredReusableCell(using: imageCellReg, for: indexPath, item: itemIdentifier)
		})
		
		var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
		snapshot.appendSections([.main])
		snapshot.appendItems(Array(0..<testImageSizes.count))
		dataSource.apply(snapshot, animatingDifferences: false)
		
	}
	
	func configLayout(){
		// don't use fractionalHeight
		//let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
		//									  heightDimension: .fractionalHeight(1.0))
		
		// instead, use estimated height
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .estimated(100.0))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension:.estimated(50))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize:groupSize, subitems: [item])
		let spacing = CGFloat(10)
		group.interItemSpacing = .fixed(spacing)
		
		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = spacing
		section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
		
		let layout = UICollectionViewCompositionalLayout(section: section)
		self.collectionView.collectionViewLayout = layout
	}
	
}
