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
    
    @IBOutlet weak var salePrice: UILabel!
    
    @IBOutlet weak var favoriteToggle: UIButton?
    
    weak var delegate: ToggleFavoriteDelegate!
    var indexPath: IndexPath!
    var favorite: Bool! {
        didSet {
            favoriteToggle?.isSelected = favorite
        }
    }
    var hasSalePrice: Bool! {
        didSet {
            salePrice.isHidden = !hasSalePrice
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: price.text!)
            if hasSalePrice {
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
            }
            self.price.attributedText = attributeString
        }
    }
    
    let impact = UIImpactFeedbackGenerator()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        favoriteToggle?.isSelected = false
        favoriteToggle?.setImage(#imageLiteral(resourceName: "favoriteIcon").withRenderingMode(.alwaysOriginal), for : .selected)
        favoriteToggle?.setImage(#imageLiteral(resourceName: "notFavoriteIcon").withRenderingMode(.alwaysOriginal), for: .normal)
        
    }
    @IBAction func toggleFavoriteAction(_ sender: Any) {
        delegate?.setFavorite(at: indexPath, isFavorite: !favorite)
        favorite = !favorite
        impact.impactOccurred()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

protocol ToggleFavoriteDelegate: class {
    func setFavorite(at index: IndexPath, isFavorite: Bool)
    func setFavorite(game: Game, isFavorite: Bool)
}
