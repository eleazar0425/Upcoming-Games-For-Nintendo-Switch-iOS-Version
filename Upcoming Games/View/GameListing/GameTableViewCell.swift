//
//  GameTableViewCell.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/14/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {

    @IBOutlet weak var boxArt: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var daysToRelease: UILabel!
    
    @IBOutlet weak var noOfPlayers: UILabel!
    
    @IBOutlet weak var releaseOn: UILabel!
    
    @IBOutlet weak var physicalRelease: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var favoriteToggle: UIButton?
    
    var delegate: ToggleFavoriteDelegate!
    var indexPath: IndexPath!
    var favorite: Bool! {
        didSet {
            favoriteToggle?.isSelected = favorite
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        favoriteToggle?.isSelected = false
        favoriteToggle?.setImage(#imageLiteral(resourceName: "favoriteIcon"), for : .selected)
        favoriteToggle?.setImage(#imageLiteral(resourceName: "notFavoriteIcon"), for: .normal)
        
    }
    @IBAction func toggleFavoriteAction(_ sender: Any) {
        delegate?.setFavorite(at: indexPath, isFavorite: !favorite)
        favorite = !favorite
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

protocol ToggleFavoriteDelegate {
    func setFavorite(at index: IndexPath, isFavorite: Bool)
}
