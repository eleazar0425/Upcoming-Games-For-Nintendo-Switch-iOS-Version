//
//  CurrencySettings.swift
//  Switch Library
//
//  Created by Eleazar Estrella GB on 2/22/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation

class CurrencySettings {
    
    private static let currencyKey = "actual_currency"
    
    static func saveCurrency(_ currency: Currency){
        UserDefaults.standard.set(currency.rawValue, forKey: currencyKey)
    }
    
    static func getCurrencySetting() -> Currency {
        let currency = Currency(rawValue: UserDefaults.standard.string(forKey: currencyKey) ?? "USD")
        return currency!
    }
}

//using ISO 4217
enum Currency: String {
    case usd = "USD"
    case cad = "CAD"
}
