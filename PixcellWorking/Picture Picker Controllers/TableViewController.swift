//
//  CommonExampleController.swift
//  AssetsPickerViewController
//
//  Created by DragonCherry on 5/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//


//This controller creates the table view where the photos are displayed after being picked and sets up all the buttons in it.

import UIKit
import Photos
import AssetsPickerViewController
import TinyLog
import Firebase

class CommonExampleController: UITableViewController {
    
    let reference = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let userID = Auth.auth().currentUser!.uid
    var picsRemaining: Int?
    
    let storage = Storage.storage() //create Firebase storage reference
    let kCellReuseIdentifier: String = UUID().uuidString
    lazy var imageManager = {
        return PHCachingImageManager()
    }()
    lazy var cellSize: CGSize = {
        return CGSize(width: self.view.bounds.width, height: 60)
    }()
    var assets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = cellSize.height
        title = "\(type(of: self))"
        navigationItem.title = NSLocalizedString("Select Images", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: - Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseIdentifier) else {
            return UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: kCellReuseIdentifier)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            assets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let asset = assets[indexPath.row] 
        
        // set title & summary
        cell.textLabel?.text = "[\(asset.mediaType == .image ? "Photo" : "Video")] \(asset.pixelWidth)x\(asset.pixelHeight)"
        cell.detailTextLabel?.text = "\(asset.creationDate?.description ?? "Unknown")"
        
        // set image
        let imageWidth = cellSize.height * UIScreen.main.scale
        imageManager.requestImage(for: asset, targetSize: CGSize(width: imageWidth, height: imageWidth), contentMode: .aspectFill, options: nil) { (image, info) in
            cell.imageView?.contentMode = .scaleAspectFill
            cell.imageView?.image = image
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)        
    }
}

/*extension CommonExampleController {
    @objc func pressedClear(_ sender: Any) {
        assets.removeAll()
        tableView.reloadData()
    }
    @objc func pressedPick(_ sender: Any) {}
    @objc func pressedSave(_ sender: Any) {}
}*/

extension CommonExampleController: AssetsPickerViewControllerDelegate {
    
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        logw("Need permission to access photo library.")
    }
    
    func assetsPickerDidCancel(controller: AssetsPickerViewController) {
        logi("Cancelled.")
    }
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        self.assets = assets
        tableView.reloadData()
    }
    
    func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        logi("shouldSelect: \(indexPath.row)")

        // can limit selection count
        if controller.selectedAssets.count > 50 {
            return false
        }
        return true
    }
    
    func assetsPicker(controller: AssetsPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath) {
        logi("didSelect: \(indexPath.row)")
    }
    
    func assetsPicker(controller: AssetsPickerViewController, shouldDeselect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        logi("shouldDeselect: \(indexPath.row)")
        return true
    }
    
    func assetsPicker(controller: AssetsPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath) {
        logi("didDeselect: \(indexPath.row)")
    }
    
    func assetsPicker(controller: AssetsPickerViewController, didDismissByCancelling byCancel: Bool) {
        logi("dismiss completed - byCancel: \(byCancel)")
    }
    
    @objc func loadLoginScreen(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "CreateAlbumController") as! CreateAlbumController
        self.present(viewController, animated: true, completion: nil)
    }
}
