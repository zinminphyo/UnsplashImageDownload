//
//  ImageCollectionViewCell.swift
//  UnsplashImageDownload
//
//  Created by Zin Min Phyoe on 12/31/19.
//  Copyright © 2019 Zin Min Phyoe. All rights reserved.
//

import UIKit
import UnsplashPhotoPicker

class ImageCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var userSelectedImageView : UIImageView!
    
    private var urlSessionDataTask : URLSessionDataTask?
    
    func downloadPhoto(_ photo:UnsplashPhoto){
        let imageURL = photo.urls[.regular]
        let session = URLSession.shared
        guard let unwrappedURL = imageURL else {  print("Error unwrapping urls.");  return }
        let dataTask = session.dataTask(with: unwrappedURL) { (data, response, error) in
            guard let unwrappedData = data else {print("Error unwrappping data"); return}
            let imageData = NSData(data: unwrappedData)
            DispatchQueue.main.async {
                self.userSelectedImageView.image = UIImage(data: imageData as Data)
            }
//            UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData as Data)!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        }
        dataTask.resume()
    }
//    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        } else {
//            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        }
//    }
    
    
}
