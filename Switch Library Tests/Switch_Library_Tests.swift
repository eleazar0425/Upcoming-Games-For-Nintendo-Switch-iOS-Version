//
//  Switch_Library_Tests.swift
//  Switch Library Tests
//
//  Created by Eleazar Estrella GB on 3/21/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import Switch_Library

class Switch_Library_Tests: XCTestCase {
    
    var game: Game!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        game = Game(withJSON: try! JSON(data:
            """
                {
                    "categories": {
                    "category": "Action"
                    },
                    "slug": "killallzombies-switch",
                    "buyitnow": "false",
                    "release_date": "Jan 24, 2019",
                    "digitaldownload": "false",
                    "nso": "false",
                    "free_to_start": "false",
                    "title": "#KILLALLZOMBIES",
                    "system": "Nintendo Switch",
                    "id": "fjMAmjAyAa0I6YXMGrZ_mzppEES3tCf4",
                    "ca_price": "25.19",
                    "number_of_players": "2 players simultaneous",
                    "nsuid": "70010000014432",
                    "eshop_price": "19.99",
                    "sale_price": "15.99",
                    "front_box_art": "https://media.nintendo.com/nintendo/bin/phxOhYo0KdnJUniiULg6lGMfnmdYvAum/OBsXqmFZbdOISYwEAZa_iGlJk2PByMSE.png",
                    "game_code": "HACNARXQA",
                    "buyonline": "true"
                }
            """.data(using: .utf8)!))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CurrencySettings.saveCurrency(.usd)
        game = nil
    }

    func testGame() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCTAssertTrue(!game.canadaPrice.isEmpty)
        XCTAssertTrue(!game.price.isEmpty)
        XCTAssertTrue(!game.computedPrice.isEmpty)
        
        let usdPrice = game.price
        let usdSalePrice = game.salePrice
        let cadPrice = game.canadaPrice
        
        CurrencySettings.saveCurrency(.usd)
        
        XCTAssertEqual(usdPrice, game.computedPrice, "Game computed price is not matching with Currency settings")
        
        XCTAssertEqual(usdSalePrice, game.computedSalePrice, "Game computed sale price is not matching with Currency settings")
        
        CurrencySettings.saveCurrency(.cad)
        
        XCTAssertEqual(cadPrice, game.computedPrice, "Game computed price is not matching with Currency settings")
        
        let cadPriceDouble = Double(cadPrice)!
        let cadSalePriceDouble = Double(game.computedSalePrice)!
        
        XCTAssertFalse( (cadPriceDouble <= cadSalePriceDouble), "Game computed canada sale price shouldn't be minor than the standar price")
        
    }
}
