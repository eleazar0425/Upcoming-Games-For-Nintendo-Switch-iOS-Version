//
//  SearchViewController.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 8/21/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var results = [Game]()
    var games: [Game]?
    var presenter: SearchPresenter?
    var filterBy: FilterBy = .all
    var actualQuery = ""

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
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
        presenter?.search(query: actualQuery, filterBy: filterBy)
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
}
