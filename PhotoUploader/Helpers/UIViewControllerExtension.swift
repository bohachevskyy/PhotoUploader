//
//  UIViewControllerExtension.swift
//  PhotoUploader
//
//  Created by Dmytro Bohachevskyi on 10/18/19.
//  Copyright © 2019 Valeria Felindash. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addActivityIndicatory() -> UIActivityIndicatorView {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        actInd.center = view.center
        actInd.hidesWhenStopped = true
        actInd.style = UIActivityIndicatorView.Style.whiteLarge
        actInd.color = .gray
        view.addSubview(actInd)
        actInd.startAnimating()
        return actInd
    }
    
}
