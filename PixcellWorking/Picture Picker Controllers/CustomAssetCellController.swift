//
//  CustomAssetCellController.swift
//  AssetsPickerViewController
//
//  Created by DragonCherry on 5/31/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

//This view controller has 3 classes and is modified from the Cocoa Pod AssetsPickerViewController. The first and second classes customize the cells, and the third class inherits from TableViewController and controlls what the picker does and how it is presented and the functions of the buttons that are presented with it and what they do. This is probably the most complex of the view controllers.
import UIKit
import Photos
import AssetsPickerViewController
import TinyLog
import PureLayout
import Firebase

class CustomAssetCellOverlay: UIView {
    
    private let countSize = CGSize(width: 40, height: 40)
    private var didSetupConstraints: Bool = false
    lazy var circleView: UIView = {
        let view = UIView.newAutoLayout()
        view.backgroundColor = .black
        view.layer.cornerRadius = self.countSize.width / 2
        view.alpha = 0.4
        return view
    }()
    let countLabel: UILabel = {
        let label = UILabel.newAutoLayout()
        let font = UIFont.preferredFont(forTextStyle: .headline)
        label.font = UIFont.systemFont(ofSize: font.pointSize, weight: UIFont.Weight.bold)
        label.textAlignment = .center
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        dim(animated: false, color: .white, alpha: 0.25)
        addSubview(circleView)
        addSubview(countLabel)
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            circleView.autoSetDimensions(to: countSize)
            circleView.autoCenterInSuperview()
            countLabel.autoSetDimensions(to: countSize)
            countLabel.autoCenterInSuperview()
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
}

class CustomAssetCell: UICollectionViewCell, AssetsPhotoCellProtocol {
    
    // MARK: - AssetsAlbumCellProtocol
    var asset: PHAsset? {
        didSet {}
    }
    
    var isVideo: Bool = false {
        didSet {}
    }
    
    override var isSelected: Bool {
        didSet { overlay.isHidden = !isSelected }
    }
    
    var imageView: UIImageView = {
        let view = UIImageView.newAutoLayout()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor(rgbHex: 0xF0F0F0)
        return view
    }()
    
    var count: Int = 0 {
        didSet { overlay.countLabel.text = "\(count)" }
    }
    
    var duration: TimeInterval = 0 {
        didSet {}
    }
    
    // MARK: - At your service
    private var didSetupConstraints: Bool = false
    
    let overlay = { return CustomAssetCellOverlay.newAutoLayout() }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        contentView.addSubview(imageView)
        contentView.addSubview(overlay)
        overlay.isHidden = true
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            imageView.autoPinEdgesToSuperviewEdges()
            overlay.autoPinEdgesToSuperviewEdges()
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
}

//This class inherits from TableViewController's CommonExampleController Class.
class CustomAssetCellController: CommonExampleController {
    
    var imagesRemaining: Int?

    var delivered: Bool?
    var submitted: Bool?
    var albumName: String?
    var albumIndex: Int?
    
    // Setting up firebase reference and UID of current user for read/write operations
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.assetCellType = CustomAssetCell.classForCoder()
        pickerConfig.assetPortraitColumnCount = 4
        pickerConfig.assetLandscapeColumnCount = 5
        
        let picker = AssetsPickerViewController(pickerConfig: pickerConfig)
        picker.pickerDelegate = self
        
        let saveButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(pressedSave))
        saveButton.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem = saveButton
        present(picker, animated: true, completion: nil)
        
        //reading from Firebase to get the Remaining Photos 
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.delivered = value?["Delivered"] as? Bool ?? false
            self.submitted = value?["Submitted"] as? Bool ?? false
        })
    }
    
    override func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        logi("shouldSelect: \(indexPath.row)")
    
        if controller.selectedAssets.count > self.imagesRemaining!-1{
            return false
        } else {
            return true
        }
    }
    
    @IBAction func homeButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //override's CommonExampleController's pressedPick function. Presents the picker, and then creates a submit button once the picker has been presented. Also enables the clear and submit buttons if there are assets chosen.
    
    
    //overrides the pressedSubmit method, does a loop up to 50 times to get the assets, convert them into JPEG format, and send them to firebase using storage refrencing. If user submits, the remaining image counter goes down by the number of loops performed, as well as segues into the CreateAlbumViewController.
    @objc func pressedSave(_ sender: Any) {
        self.assets = assets
        tableView.reloadData()
        guard let imagesRemaining = self.imagesRemaining, let albumName = self.albumName, let indexPath = self.albumIndex else {return}
        let imageSize = CGSize(width: view.bounds.inset(by: view.safeAreaInsets).width, height: view.bounds.inset(by: view.safeAreaInsets).height)
        if assets.count < 51 {
            let ac = UIAlertController(title: NSLocalizedString("Images Selected", comment: ""), message: NSLocalizedString("message for images selected", comment: ""), preferredStyle: .alert)
            let action = UIAlertAction(title: NSLocalizedString("Yes I am Sure", comment: ""), style: .default, handler: { action in
                for i in 0...self.assets.count - 1 {
                    self.imageManager.requestImage(for: self.assets[i], targetSize: imageSize, contentMode: .aspectFill, options: nil) { image, _ in
                        guard let imageJPEG = image?.jpegData(compressionQuality: 1) else {
                            return
                        }
                        var filePath = ""
                        if imagesRemaining > 0 && imagesRemaining <= 50 {
                            filePath = Auth.auth().currentUser!.uid +
                            "/\(albumName)/\(50-imagesRemaining+i+1) of 50 taken on \((self.assets[i].creationDate!).yearMonthDayDash())".replacedArabicDigitsWithEnglish
                            self.ref.child("users/\(self.uid)/Albums/\(Date().getMonthName())/\(indexPath)").setValue([[albumName:(imagesRemaining-self.assets.count)], false, false])
                        }
                        let storageRef = self.storage.reference(withPath: filePath)
                        storageRef.putData(imageJPEG, metadata: nil) { (metadata, error) in
                            guard let metadata = metadata else {
                                return
                            }
                        }
                    }
                }
                self.performSegue(withIdentifier: "PicturesSavedSegue", sender: self)
            })
            let pickMorePics = UIAlertAction(title: NSLocalizedString("Return to image picker", comment: ""), style: .cancel, handler: { _ in
                let pickerConfig = AssetsPickerConfig()
                pickerConfig.assetCellType = CustomAssetCell.classForCoder()
                pickerConfig.assetPortraitColumnCount = 4
                pickerConfig.assetLandscapeColumnCount = 5
                
                let picker = AssetsPickerViewController(pickerConfig: pickerConfig)
                picker.pickerDelegate = self
                
                self.present(picker, animated: true, completion: nil)
            })
            ac.addAction(pickMorePics)
            ac.addAction(action)
            present(ac, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PicturesSavedSegue" {
            let dest = segue.destination as! CreateAlbumController
        }
    }
}
