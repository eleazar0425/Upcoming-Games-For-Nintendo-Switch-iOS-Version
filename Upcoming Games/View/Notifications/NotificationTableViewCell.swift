//
//  NotificationTableViewCell.swift
//  Switch Library
//
//  Created by Eleazar Estrella GB on 1/29/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var boxArt: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
