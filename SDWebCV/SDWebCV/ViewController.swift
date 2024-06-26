//
//  ViewController.swift
//  SDWebCV
//
//  Created by Don Mag on 4/26/24.
//

import UIKit
import SDWebImage

class MyImageView: UIImageView {
	var myHeight: CGFloat = 0
	
	override var image: UIImage? {
		didSet {
			updateHeight()
		}
	}
//	override var bounds: CGRect {
//		didSet {
//			updateHeight()
//		}
//	}
	func updateHeight() {
		if let img = image {
			myHeight = bounds.width * (img.size.height / img.size.width)
			invalidateIntrinsicContentSize()
		}
	}
	override var intrinsicContentSize: CGSize {
		print("ics")
		var sz = super.intrinsicContentSize
		if let img = image {
			sz = img.size
		}
		return sz // .init(width: sz.width, height: myHeight)
	}
}
class ViewController: UIViewController {
	enum Section {
		case main
	}
	
	// we will use these sizes to configure URLs to get
	//	sample images to download
	// we'll load the Google image as the first image
	var testImageSizes: [CGSize] = [
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
		
		for w in 360...370 {
			for h in 200...202 {
				testImageSizes.append(.init(width: w, height: h))
			}
		}
		
		//self.configDataSource()
		//self.myConfigDataSource()
		self.textConfigDataSource()

		self.configLayout()
	}
	
	func textConfigDataSource() {
		let imageCellReg = UICollectionView.CellRegistration<MyTextCell,Int>(cellNib: UINib(nibName: "MyTextCell", bundle: nil)) { cell, indexPath, itemIdentifier in
			
			// alternate cell background colors
			cell.contentView.backgroundColor = indexPath.item % 2 == 0 ? .green : .cyan
			
			cell.theLabel.text = "\(indexPath)"
			cell.delayedText(str: "This is multiline text\nSet after a delay.")
		}
		self.dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
			return self.collectionView.dequeueConfiguredReusableCell(using: imageCellReg, for: indexPath, item: itemIdentifier)
		})
		
		var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
		snapshot.appendSections([.main])
		snapshot.appendItems(Array(0..<testImageSizes.count))
		dataSource.apply(snapshot, animatingDifferences: false)
		
	}
	

	func configDataSource() {
		let imageCellReg = UICollectionView.CellRegistration<ImageCell,Int>(cellNib: UINib(nibName: "ImageCell", bundle: nil)) { cell, indexPath, itemIdentifier in
			
			print("ip:", indexPath)
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

					print("sd completion")
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
	
	func myConfigDataSource() {
		let imageCellReg = UICollectionView.CellRegistration<MyImageCell,Int>(cellNib: UINib(nibName: "MyImageCell", bundle: nil)) { cell, indexPath, itemIdentifier in
			
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
			
			cell.imageContentView.sd_setImage(
				with: URL(string: urlStr),
				completed: { [weak self] img, err, ct, url in
					guard let self = self else { return }
					self.collectionView.collectionViewLayout.invalidateLayout()
				})
				
//			cell.imageContentView.sd_setImage (
//				with: URL(string: urlStr),
//				placeholderImage: UIImage(named: "somePlaceholder"),
//				options: SDWebImageOptions(rawValue: 0),
//				completed: { [weak self] image, error, cacheType, imageURL in
//					guard let self = self,
//						  let img = image
//					else { return }
//					// tell the collection view to re-layout the cells
//					self.collectionView.collectionViewLayout.invalidateLayout()
//				}
//			)
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

class SimpleViewController: UIViewController {
	
	let imgV1 = MyImageView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imgV1.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(imgV1)

		let g = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			imgV1.topAnchor.constraint(equalTo: g.topAnchor, constant: 20.0),
			imgV1.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20.0),
			imgV1.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20.0),
		])
		
		imgV1.backgroundColor = .red
		//imgV1.contentMode = .scaleAspectFit
		
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		//	e.g. "https://dummyimage.com/300x200.png"
		var urlStr: String = "https://dummyimage.com/800x400.png"
		
		imgV1.sd_setImage (
			with: URL(string: urlStr),
			placeholderImage: UIImage(named: "somePlaceholder"),
			options: SDWebImageOptions(rawValue: 0),
			completed: { [weak self] image, error, cacheType, imageURL in
//				guard let self = self,
//					  let img = image
//				else { return }
//				
//				// calculate proportional height
//				let iw = self.imgV1.frame.width
//				let ih = (img.size.height / img.size.width) * iw
//				
//				// update the height contraint in the cell
//				//cell.imgHeight.constant = ih
				
			}
		)
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		print(imgV1.intrinsicContentSize)
	}
}
