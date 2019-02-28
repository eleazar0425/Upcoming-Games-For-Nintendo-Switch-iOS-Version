//
//  Double+Round.swift
//  Switch Library
//
//  Created by Eleazar Estrella GB on 2/28/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

