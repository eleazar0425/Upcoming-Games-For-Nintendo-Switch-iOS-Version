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

class SearchViewController: UIViewController {
    
    var results = [Game]()
    var games: [Game]?
    var presenter: SearchPresenter!
    var filterBy: FilterBy = .all
    var actualQuery = ""
    weak var delegate: FavoriteChangedOnSearch?

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib.init(nibName: "GameViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "GameCellIdentifier")
        
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

extension SearchViewController : ToggleFavoriteDelegate {
    func setFavorite(at index: IndexPath, isFavorite: Bool) {
        let game = results[index.row]
        var message = ""
        if isFavorite {
            presenter.saveFavorite(id: game.id)
            message = "\(game.title) has been added to favorites"
            let content = UNMutableNotificationContent()
            content.title = "Beep, boop!"
            content.body = "\(game.title) is releasing today!"
            content.sound = UNNotificationSound.default
            
            let releaseDate = DateUtil.parse(from: game.releaseDate)!
            
            let calendar = Calendar.current
            
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: releaseDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let identifier = "FavoriteGameReleasedNotification-\(game.id)"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print("something went wrong!")
                }
            })
        }else{
            presenter.deleteFavorite(id: game.id)
            message = "\(game.title) has been removed from favorites"
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["FavoriteGameReleasedNotification-\(game.id)"])
        }
        
        self.delegate?.favoriteDidChange(game: game, isFavorite: isFavorite)
        
        self.view.makeToast(message)
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
        cell.price.text = (game.price != "" ? "$\(game.price)": "TBA" )
        cell.physicalRelease.text = "Physical release: \(game.physicalRelease ? "Yes" : "No")"
        
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
}

protocol FavoriteChangedOnSearch: class {
    func favoriteDidChange(game: Game, isFavorite: Bool)
}
