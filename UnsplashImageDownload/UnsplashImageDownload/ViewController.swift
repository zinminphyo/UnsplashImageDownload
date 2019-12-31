//
//  ViewController.swift
//  UnsplashImageDownload
//
//  Created by Zin Min Phyoe on 12/31/19.
//  Copyright © 2019 Zin Min Phyoe. All rights reserved.
//

import UIKit
import UnsplashPhotoPicker

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UnsplashPhotoPickerDelegate {
    
    @IBOutlet weak var userSearchPhtoTextField: UITextField!
    var userSelectedImages : [UnsplashPhoto] = []
    @IBOutlet weak var selectedImagesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedImagesCollectionView.reloadSections(IndexSet(integer: 0))
    }

    @IBAction func didTapSearchButton(_ sender: UIButton) {
        let configuration = UnsplashPhotoPickerConfiguration(accessKey: Constants.ACCESS_KEY, secretKey: Constants.SECRET_KEY,query: userSearchPhtoTextField.text,allowsMultipleSelection: true)
        let unsplahPhotoPicker = UnsplashPhotoPicker(configuration: configuration)
        unsplahPhotoPicker.photoPickerDelegate = self as? UnsplashPhotoPickerDelegate
        present(unsplahPhotoPicker, animated: true, completion: nil)
    }
    func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
        for photo in photos {
            userSelectedImages.append(photo)
        }
        selectedImagesCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userSelectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let userSelectedImage = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.IMAGE_IDENTIFIER, for: indexPath) as! ImageCollectionViewCell
        let imageURL = userSelectedImages[indexPath.row].urls[.regular]
        let session = URLSession.shared
        guard let unwrappedURL = imageURL else {  print("Error unwrapping urls.");  return userSelectedImage}
        let dataTask = session.dataTask(with: unwrappedURL) { (data, response, error) in
            guard let unwrappedData = data else {print("Error unwrappping data"); return}
            let imageData = NSData(data: unwrappedData)
            DispatchQueue.main.async {
                userSelectedImage.userSelectedImageView.image = UIImage(data: imageData as Data)
                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData as Data)!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        dataTask.resume()
        
        return userSelectedImage
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

}


