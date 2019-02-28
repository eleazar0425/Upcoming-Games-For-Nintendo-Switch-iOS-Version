//
//  SearchViewController.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 8/21/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import UIKit
import Toast_Swift
import UserNotifications
import SwiftEventBus

class SearchViewController: UIViewController {
    
    var results = [Game]()
    var games: [Game]?
    var presenter: SearchPresenter!
    var filterBy: FilterBy = .all
    var actualQuery = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        SwiftEventBus.onMainThread(self, name: "favoritesUpdate") { result in
            let event = result?.object as! FavoriteEvent
            guard let index = self.results.firstIndex(where: { game  in
                game.id == event.game.id
            }) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        SwiftEventBus.onMainThread(self, name: "currencyUpdate") { _ in
            self.tableView.reloadData()
        }

        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib.init(nibName: "GameViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "GameCellIdentifier")
        registerForPreviewing(with: self, sourceView: tableView)
        
        self.searchBar.tintColor = UIColor.orange
        self.searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        self.searchBar.scopeButtonTitles = ["All", "Digital", "Physical"]
        
        self.searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    
    func performSearch(){
        presenter.search(query: actualQuery, filterBy: filterBy)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameDetailSegue" {
            let destination = segue.destination as! GameDetailViewController
            let game = sender as! Game
            destination.game = game
        }
    }
}

extension SearchViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        actualQuery = searchText
        performSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //todo hide keyboard
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            filterBy = .all
            break
        case 1:
            filterBy = .digitalOnly
            break
        case 2:
            filterBy = .physicalOnly
            break
        default:
            filterBy = .all
        }
        performSearch()
    }
}

extension SearchViewController : SearchProtocol {
    func setResults(games: [Game]?, error: Error?) {
        if let results = games {
            self.results = results
            self.tableView.reloadData()
        }
    }
}

extension SearchViewController: ToggleFavoriteDelegate {
    func setFavorite(at index: IndexPath, isFavorite: Bool) {
        let game = results[index.row]
        var message = ""
        if isFavorite {
            presenter.saveFavorite(id: game.id)
            message = "\(game.title) has been added to favorites"
            LocalNotificationUtil.scheduleNotification(for: game, notificationType: .releasedGame)
        }else{
            presenter.deleteFavorite(id: game.id)
            message = "\(game.title) has been removed from favorites"
            LocalNotificationUtil.removePendingNotifications(to: game)
        }

        SwiftEventBus.post("favoritesUpdate", sender: FavoriteEvent(game: game, isFavorite: isFavorite))
        
        self.view.makeToast(message)
    }
    
    func setFavorite(game: Game, isFavorite: Bool) {
        guard let index = results.firstIndex(of: game) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        self.setFavorite(at: indexPath, isFavorite: isFavorite)
    }
}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "GameCellIdentifier"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            as? GameTableViewCell else {
                fatalError("The dequeued cell is not an instance of TableViewCell")
        }
        
        let game = results[indexPath.row]
        
        cell.title.text = game.title
        cell.releaseOn.text = game.releaseDate
        cell.boxArt.setImage(withPath: game.boxArt, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        cell.price.text = (game.computedPrice != "" ? "$\(game.computedPrice)": "TBA" )
        cell.physicalRelease.text = "Physical release: \(game.physicalRelease ? "Yes" : "No")"
        
        let salePrice = game.computedSalePrice
        if !salePrice.isEmpty {
            cell.hasSalePrice = true
            cell.salePrice.text = "$\(salePrice)"
        }else{
            cell.hasSalePrice = false
        }
        
        guard let releaseDate = DateUtil.parse(from: game.releaseDate),
            let daysToRelease = DateUtil.daysBetweenDates(Date(), releaseDate) else {
                return cell
        }
        
        if daysToRelease > 0 {
            cell.daysToRelease.text = "\(daysToRelease) \(daysToRelease == 1 ? "day" : "days") to release"
        }else{
            cell.daysToRelease.text = "Already released"
        }
        
        cell.indexPath = indexPath
        cell.favorite = presenter.isFavorite(id: game.id)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = self.results[indexPath.row]
        performSegue(withIdentifier: "gameDetailSegue", sender: game)
    }
}

extension SearchViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let viewController = storyboard?.instantiateViewController(withIdentifier: "gameDetailViewController") as! GameDetailViewController
        viewController.game = self.results[indexPath.row]
        return viewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
