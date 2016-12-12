//
//  TourAppAvatarView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 04/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

typealias TourAppAvatarMVP = MVPContainer<TourAppAvatarView, TourAppAvatarPresenter, TourAppAvatarModel>

protocol ITourAppAvatarView: class {
    func updateView(title: String)
    func updateView(avatarURL: URL)
    func setLoadingState(_ state: LoadingState)
    func showBackendErrorView(_ description: ErrorHumanDescription)
    func showErrorView()
    func showPurchasesView()
    func showConversationView()
}

class TourAppAvatarView: UIViewController {
    static let identifier = "TourAppAvatarView"
    
    enum SegueIdentifier: String {
        case toSecondStep = "toThirdStep"
    }
    
    @IBOutlet weak var avatarView: UIImageView!
    
    var presenter: ITourAppAvatarPresenterView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsManager.shared.trackScreen(named: "Tour app avatar screen", viewController: self)
        
        let _ = TourAppAvatarMVP(controller: self)
        self.presenter?.viewLoaded()
    }
    
    @IBAction func photoPressed(_ sender: AnyObject) {
        self.presentChoosingPhotoSourceController()
    }
    
    @IBAction func skipPressed(_ sender: AnyObject) {
        ShowConversationViewController()
    }
}

extension TourAppAvatarView {
    func presentChoosingPhotoSourceController() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) {[weak self](alert: UIAlertAction!) -> Void in
            guard let sself = self else {return}
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = sself
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            sself.present(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(takePhoto)
        
        let library = UIAlertAction(title: "Choose from Library", style: .default) {[weak self](alert: UIAlertAction!) -> Void in
            guard let sself = self else {return}
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = sself
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            sself.present(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(library)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension TourAppAvatarView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        DispatchQueue.main.async(execute: {[weak self] () -> Void in
            guard let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
            self?.presenter?.imageReceived(image: pickedImage)
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension TourAppAvatarView: ITourAppAvatarView {
    func updateView(title: String) {
        self.title = title
    }
    
    func updateView(avatarURL: URL) {
        self.avatarView.sd_setImage(with: avatarURL) { (image, error, cacheType, url) in
            SVProgressHUD.dismiss()
            if let _ = error {ShowErrorAlert(); return}
        }
    }
    
    func setLoadingState(_ state: LoadingState) {
        switch state {
        case .loading:
            SVProgressHUD.show()
        case .done:
            ShowConversationViewController()
        case .failed:
            SVProgressHUD.dismiss()
        }
    }
    
    func showBackendErrorView(_ description: ErrorHumanDescription) {
        ShowErrorAlert(description.title, message: description.text)
    }
    
    func showErrorView() {
        ShowErrorAlert()
    }
    
    func showPurchasesView() {
        self.performSegue(withIdentifier: SegueIdentifier.toSecondStep.rawValue, sender: self)
    }
    
    func showConversationView() {
        ShowConversationViewController()
    }
}

extension TourAppAvatarView: MVPView {
    typealias PresenterProtocol = ITourAppAvatarPresenterView
}
