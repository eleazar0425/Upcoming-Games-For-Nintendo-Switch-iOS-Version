//
//  TodayViewController.swift
//  Switch Library Widget
//
//  Created by Eleazar Estrella GB on 3/8/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import UIKit
import NotificationCenter
import AlamofireImage
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var dataManager: GameLocalDataManager!
    var games = [Game]()
        
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.switchlibrary")!
            .appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: fileURL, deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
        let realm =  try! Realm()
        dataManager = GameLocalDataManager(realm: realm)
        
        games += dataManager.getDiscountedFavoritesGames() ?? []
        collectionView.delegate = self
        collectionView.dataSource = self
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

extension TodayViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "discountWidgetViewCell", for: indexPath) as! DiscountWidgetCollectionViewCell
        let game = games[indexPath.item]
        let url = try? game.boxArt.asURL()
        viewCell.coverArt.af_setImage(withURL: url!)
        viewCell.discountLabel.text = "\(game.discountPercentage())% off"
        return viewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //redirect
        let game = games[indexPath.item]
        extensionContext?.open(URL(string: "com.switchlibrary://gameDetail?id="+game.id)!, completionHandler: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
}
