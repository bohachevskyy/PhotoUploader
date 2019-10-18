//
//  PhotoUploaderVC.swift
//  PhotoUploader
//
//  Created by Dmytro Bohachevskyi on 10/17/19.
//  Copyright © 2019 Valeria Felindash. All rights reserved.
//

import UIKit
import Firebase

class PhotoUploaderVC: UIViewController {
    static private let cellId = "photoCell"
    static private let cellHeight: CGFloat = 56.0
    
    @IBOutlet private weak var tableView: UITableView!
    
    // Create a root reference
    lazy var storageRef = Storage.storage().reference()
    lazy var refreshControl = UIRefreshControl()
    var references: [URL: StorageReference] = [:] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Loader"
        tableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(getData), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        getData()
    }
    
    @IBAction private func addDidTap(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] (_) in
            self?.presentPikcer(withSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] (_) in
            self?.presentPikcer(withSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func presentPikcer(withSourceType sourceType: UIImagePickerController.SourceType) {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = sourceType
        imagePickerVC.allowsEditing = false
        present(imagePickerVC, animated: true)
    }
    
    @objc private func getData() {
        refreshControl.endRefreshing()
        references = [:]
        let storageReference = storageRef.child("images")
        storageReference.listAll { (result, error) in
            result.items.forEach { item in
                item.downloadURL { [weak self] (url, _) in
                    guard let url = url else {
                        return
                    }
                    self?.references[url] = item
                }
            }
        }
    }
    
    private func uploadPhoto(_ photo: UIImage) {
        guard let data = photo.jpegData(compressionQuality: 0.9) else {
            return
        }
        let uuid = UUID().uuidString
        let imageRef = storageRef.child("images/\(uuid).jpg")
        let activityIndicator = addActivityIndicatory()
        
        imageRef.putData(data, metadata: nil) { (metadata, error) in
            if nil != error {
                activityIndicator.removeFromSuperview()
                return
            }
            
            imageRef.downloadURL { [weak self] (url, error) in
                activityIndicator.removeFromSuperview()
                guard let downloadURL = url else {
                    return
                }
                
                self?.references[downloadURL] = imageRef
            }
        }
    }
    
}

extension PhotoUploaderVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            uploadPhoto(image)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PhotoUploaderVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PhotoUploaderVC.cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return references.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoUploaderVC.cellId, for: indexPath) as? PhotoCell else {
            return UITableViewCell()
        }
        
        let url = Array(references.keys)[indexPath.row]
        let ref = references[url]
        if let fileNameSubstring = ref?.fullPath.split(separator: "/").last {
            cell.photoNameLabel.text = String(fileNameSubstring)
        } else {
            cell.photoNameLabel.text = ""
        }

        cell.showImage(url)
        return cell
    }
    
}
