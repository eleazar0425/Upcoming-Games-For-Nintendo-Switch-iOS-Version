//
//  NotificationSettingsViewController.swift
//  Switch Library Widget
//
//  Created by Eleazar Estrella GB on 3/11/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import UIKit
import SwiftEventBus

class NotificationSettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var presenter: NotificationSettingsPresenter!
    var games = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftEventBus.onMainThread(self, name: "favoritesUpdate") { result in
            self.presenter.getGames()
        }
        
        presenter.getGames()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension NotificationSettingsViewController: NotificationSettingsView {
    func setGames(games: [Game]?, error: Error?) {
        guard let games = games else { return }
        self.games.removeAll()
        self.games += games
        self.tableView.reloadData()
    }
}

extension NotificationSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewCell = tableView.dequeueReusableCell(withIdentifier: "notificationSettingViewCell", for: indexPath) as! NotificationSettingTableViewCell
        let game = games[indexPath.row]
        viewCell.boxArt.setImage(withPath: game.boxArt)
        viewCell.gameTitle.text = game.title
        viewCell.suscriptionSwitch.isOn = presenter.isSuscribed(game: game)
        viewCell.row = indexPath.row
        viewCell.delegate = self
        return viewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NotificationSettingTableViewCell
        let game = self.games[indexPath.row]
        let newSeleccion = !cell.suscriptionSwitch.isOn
        cell.suscriptionSwitch.isOn = newSeleccion
        if newSeleccion {
            presenter.suscribe(game: game)
        }else {
            presenter.unsuscribe(game: game)
        }
    }
}

extension NotificationSettingsViewController: SwitchChangedDelegate {
    func changeStateTo(isOn: Bool, row: Int) {
        let game = self.games[row]
        if isOn {
            presenter.suscribe(game: game)
        }else{
            presenter.unsuscribe(game: game)
        }
    }
}


