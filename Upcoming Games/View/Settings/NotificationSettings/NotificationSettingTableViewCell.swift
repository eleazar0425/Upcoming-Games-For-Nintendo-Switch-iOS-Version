//
//  NotificationSettingTableViewCell.swift
//  Switch Library Widget
//
//  Created by Eleazar Estrella GB on 3/11/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import UIKit

class NotificationSettingTableViewCell: UITableViewCell {
    @IBOutlet weak var boxArt: UIImageView!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var suscriptionSwitch: UISwitch!
    var delegate: SwitchChangedDelegate?
    var row: Int?
    
    @IBAction func changedSwitchValue(_ sender: Any) {
        guard let row = row else { return }
        delegate?.changeStateTo(isOn: suscriptionSwitch.isOn, row: row)
    }
}

protocol SwitchChangedDelegate {
    func changeStateTo(isOn: Bool, row: Int)
}
