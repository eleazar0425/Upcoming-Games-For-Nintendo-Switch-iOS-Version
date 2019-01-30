//
//  SettingsViewController.swift
//  Switch Library
//
//  Created by Eleazar Estrella GB on 1/30/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import UIKit
import SwiftMessages
import SwiftEventBus

class SettingsViewController: UITableViewController {
    
    let documentInteractionController = UIDocumentInteractionController()
    var interactor: GameListInteractor!
    let notification = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentInteractionController.delegate = self
    }
    
    func exportFavorites(){
        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("switch-library-backup-file.json")
        let favorites = interactor.getFavorites()?.map { $0.id }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: favorites!, options: [])
            try data.write(to: tmpURL)
        } catch {
            print(error)
        }
        
        DispatchQueue.main.async {
            self.documentInteractionController.url = tmpURL
            self.documentInteractionController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
        }
    }
    
    func importFavorites(){
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.text"], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func showAboutUsAlert(){
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            exportFavorites()
        case 1:
            importFavorites()
        case 2:
            showAboutUsAlert()
        default:
            return
        }
    }
}

extension SettingsViewController: UIDocumentInteractionControllerDelegate, UIDocumentPickerDelegate {
    /// If presenting atop a navigation stack, provide the navigation controller in order to animate in a manner consistent with the rest of the platform
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navigationController = self.navigationController else {
            return self
        }
        return navigationController
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            guard urls.count > 0 else { return }
            let url = urls[0]
            do {
                let data = try Data(contentsOf: url, options: [])
                guard let favoritesArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String] else { return errorReadingBackupFile() }
                for favorite in favoritesArray {
                    interactor.saveFavorite(favorite)
                    SwiftEventBus.post("favoritesUpdate", sender: FavoriteEvent(game: Game(id: favorite), isFavorite: true))
                }
                notification.notificationOccurred(.success)
                SwiftMessages.show {
                    let view = MessageView.viewFromNib(layout: .cardView)
                    view.configureTheme(.success)
                    view.configureDropShadow()
                    view.configureContent(title: "Success", body: "\(favoritesArray.count) games imported successfuly to your favorites")
                    view.button?.isHidden = true
                    return view
                }
            } catch {
                errorReadingBackupFile()
            }
        }
    }
    
    func errorReadingBackupFile(){
        notification.notificationOccurred(.error)
        SwiftMessages.show {
            let view = MessageView.viewFromNib(layout: .cardView)
            view.configureTheme(.error)
            view.configureDropShadow()
            view.configureContent(title: "Error", body: "Invalid backup file")
            view.button?.isHidden = true
            return view
        }
    }
}


