//
//  GameDetailViewController.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella GB on 1/19/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import UIKit
import YouTubePlayer
import SwiftEventBus

class GameDetailViewController: UIViewController {

    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var numberOfPlayers: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var salePrice: UILabel!
    @IBOutlet weak var videoPlayer: YouTubePlayerView!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    var game: Game!
    var presenter: GameDetailPresenter!
    
    @objc let favoriteToggle = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = game, let _ = presenter else {
            fatalError("You must set the 'game' and 'presenter' property in order to use this view controller ")
        }
        
        SwiftEventBus.onMainThread(self, name: "favoritesUpdate") { result in
            let event = result?.object as! FavoriteEvent
            if self.game.id == event.game.id {
                self.favoriteToggle.isSelected = event.isFavorite
            }
        }
        
        favoriteToggle.isSelected = false
        favoriteToggle.setImage(#imageLiteral(resourceName: "favoriteIcon").withRenderingMode(.alwaysOriginal), for : .selected)
        favoriteToggle.setImage(#imageLiteral(resourceName: "notFavoriteIcon").withRenderingMode(.alwaysOriginal), for: .normal)
        favoriteToggle.contentMode = .scaleToFill
        favoriteToggle.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        favoriteToggle.translatesAutoresizingMaskIntoConstraints = false
        // all constaints
        let widthContraints =  NSLayoutConstraint(item: favoriteToggle, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
        let heightContraints = NSLayoutConstraint(item: favoriteToggle, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
       
        NSLayoutConstraint.activate([heightContraints,widthContraints])
        
        favoriteToggle.addTarget(self, action: #selector(favoriteToggleAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteToggle)
        
        favoriteToggle.isSelected = presenter.isFavorite(id: self.game.id)
        
        gameTitle.text = game.title
        releaseDate.text = game.releaseDate
        genres.text = game.categories
        numberOfPlayers.text = game.numberOfPlayers
        
        price.text = "$\(game.price)"
        if !game.salePrice.isEmpty {
            salePrice.text = "$\(game.salePrice)"
            salePrice.isHidden = false
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: price.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
            self.price.attributedText = attributeString
        }

        presenter.getGameTrailer(game: self.game)
        presenter.getGameDescription(game: self.game)
    }
    
    @objc func favoriteToggleAction() {
        favoriteToggle.isSelected = !favoriteToggle.isSelected
        if favoriteToggle.isSelected {
            presenter.saveFavorite(id: self.game.id)
        }else{
            presenter.deleteFavorite(id: self.game.id)
        }
        SwiftEventBus.post("favoritesUpdate", sender: FavoriteEvent(game: game, isFavorite: favoriteToggle.isSelected))
    }
}

extension GameDetailViewController: GameDetailView {
    func setGameTrailerVideoId(videoId: String?, error: Error?) {
        videoPlayer.loadVideoID(videoId ?? "f5uik5fgIaI")
    }
    
    func setGameDescription(description: String?, error: Error?) {
        self.descriptionLabel.text = description ?? ""
    }
}
