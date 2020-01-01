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
    
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var userSearchPhtoTextField: UITextField!
    var userSelectedImages : [UnsplashPhoto] = []
    @IBOutlet weak var selectedImagesCollectionView: UICollectionView!
    var bottomConstraint : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedImagesCollectionView.reloadSections(IndexSet(integer: 0))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
      //  bottomConstraint = NSLayoutConstraint(item: searchBtn!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
      //  self.view.addConstraint(bottomConstraint!)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.selectedImagesCollectionView.contentInset.bottom = searchBtn.frame.height
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
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        let curveRawValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
        let curve: UIView.AnimationCurve = UIView.AnimationCurve(rawValue: curveRawValue) ?? .easeInOut

        UIViewPropertyAnimator(duration: duration, curve: curve, animations: {            self.additionalSafeAreaInsets.bottom = self.view.frame.height - endFrame.origin.y
            self.view.layoutIfNeeded()
            print("Search button frame height is \(self.searchBtn.frame.height)")
        }).startAnimation()
    }

}


