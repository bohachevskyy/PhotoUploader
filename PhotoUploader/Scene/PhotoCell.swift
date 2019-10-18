//
//  PhotoCell.swift
//  PhotoUploader
//
//  Created by Dmytro Bohachevskyi on 10/18/19.
//  Copyright © 2019 Valeria Felindash. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoNameLabel: UILabel!
    
    private var downloadTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        imageView?.contentMode = .scaleAspectFit
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
        photoImageView.image = nil
    }
    
    func showImage(_ url: URL) {
        downloadTask = ImageDownloadManager.downloadImage(url) { [weak self] (result) in
            switch result {
            case .success(let image):
                self?.photoImageView?.image = image
            case .failure(_):
                break
            }
        }
    }
    
}
