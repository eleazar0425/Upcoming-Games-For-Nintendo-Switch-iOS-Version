//
//  GamesViewController.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/14/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import UIKit
import Toast_Swift

class GamesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var games = [Game]()
    var backup: [Game]?
    
    var filterState: FilterBy = .all
    var orderByState: OrderBy = .releaseDate
    
    var presenter: GameListPresenter?
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(GamesViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.orange
        
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        
        prepareActivityIndicator()
        activityIndicator.startAnimating()
        presenter?.getGameList()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SearchViewController
        destination.games = backup
    }
    
    func prepareActivityIndicator(){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl){
        presenter?.getGameList()
    }
    
    
    @IBAction func sortAction(_ sender: Any) {
         let alertController = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        
        let byTitle = UIAlertAction(title: "Title", style: .default) { _ in
            self.order(by: .title)
        }
        
        let byDate = UIAlertAction(title: "Release date", style: .default) { _ in
            self.order(by: .releaseDate)
        }
        
        let byHighestPrice = UIAlertAction(title: "Highest price", style: .default) { _ in
            self.order(by: .highestPrice)
        }
        
        let byLowestPrice = UIAlertAction(title: "Lowest price", style: .default) { _ in
            self.order(by: .lowestPrice)
        }
        
        alertController.addAction(byTitle)
        alertController.addAction(byDate)
        alertController.addAction(byLowestPrice)
        alertController.addAction(byHighestPrice)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func filterAction(_ sender: Any) {
       
        let alertController = UIAlertController(title: "Filter by", message: nil, preferredStyle: .actionSheet)
       
        let filterPhysicalOnly = UIAlertAction(title: "Digital only", style: .default) { _ in
            self.filter(by: .digitalOnly)
        }
        
        let filterDigitalOnly = UIAlertAction(title: "Physical only", style: .default) { _ in
            self.filter(by: .physicalOnly)
        }
        
        let filterFavorites = UIAlertAction(title: "Favorites", style: .default) { _ in
            self.filter(by: .favorites)
        }
        
        let filterAll = UIAlertAction(title: "All", style: .default) { _ in
            self.filter(by: .all)
        }
        
        alertController.addAction(filterAll)
        alertController.addAction(filterFavorites)
        alertController.addAction(filterPhysicalOnly)
        alertController.addAction(filterDigitalOnly)
        
        self.present(alertController, animated: true, completion: nil)
    }
}


extension GamesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO
    }
}


extension GamesViewController : UITableViewDataSource, ToggleFavoriteDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "GameCellIdentifier"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                as? GameTableViewCell else {
            fatalError("The dequeued cell is not an instance of TableViewCell")
        }
        
        let game = games[indexPath.row]
        
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
        cell.favorite = presenter?.isFavorite(id: game.id)
        cell.delegate = self
    
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func setFavorite(at index: IndexPath, isFavorite: Bool) {
        let game = games[index.row]
        var message = ""
        if isFavorite {
            presenter?.saveFavorite(id: game.id)
            message = "\(game.title) has been added to favorites"
        }else{
            presenter?.deleteFavorite(id: game.id)
            message = "\(game.title) has been removed from favorites"
        }
        
        self.view.makeToast(message)
    }
}

extension GamesViewController : GameListProtocol {
    func setGameList(games: [Game]?, error: Error?){
        guard let gamesResult = games else {
            return showErrorMessage()
        }
        self.games += gamesResult
        self.backup = games
        order(by: orderByState)
        filter(by: filterState)
        tableView.reloadData()
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
    }
    
    func showErrorMessage(){
        let alert = UIAlertController(title: "Error", message: "There was an error, plase try again later", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.activityIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
    }
    
    func order(by: OrderBy, fromFilter: Bool = false){
        guard let sortedGames =  presenter?.order(games: games, by: by) else { return }
        self.games = sortedGames
        if !fromFilter {
            filter(by: filterState, fromOrderBy: true)
        }
        self.orderByState = by
        self.tableView.reloadData()
    }
    
    func filter(by: FilterBy, fromOrderBy: Bool = false){
        guard let filteredGames = presenter?.filter(games: games, by: by) else { return }
        
        guard by != .all else {
            if let backupGames = self.backup {
                self.games = backupGames
                order(by: orderByState, fromFilter: true)
                self.tableView.reloadData()
            }
            return
        }
        
        if !fromOrderBy {
            order(by: orderByState, fromFilter: true)
        }
        
        self.games = filteredGames
        self.filterState = by
        self.tableView.reloadData()
    }
}
