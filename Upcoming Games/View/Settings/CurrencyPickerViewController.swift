//
//  CurrencyPickerViewController.swift
//  Switch Library
//
//  Created by Eleazar Estrella GB on 2/28/19.
//  Copyright © 2019 Eleazar Estrella. All rights reserved.
//

import Foundation
import UIKit
import WheelPicker
import SwiftEventBus

class CurrencyPickerViewController: UIViewController {
    
    @IBOutlet weak var picker: WheelPicker!
    
    let pickerData = ["USD", "CAD"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.interitemSpacing = 25.0
        picker.fisheyeFactor = 0.001
        picker.style = .styleFlat
        picker.isMaskDisabled = true
        picker.scrollDirection = .vertical
        
        picker.textColor = UIColor.orange.withAlphaComponent(0.5)
        picker.highlightedTextColor = UIColor.orange
        
        let index = pickerData.firstIndex(of: CurrencySettings.getCurrencySetting().rawValue) ?? 0
        
        picker.dataSource = self
        picker.delegate = self
        
        picker.select(index, animated: true)
    }
    
    @IBAction func okeyAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        SwiftEventBus.post("currencyUpdate")
    }
}

extension CurrencyPickerViewController: WheelPickerDelegate, WheelPickerDataSource {
    func numberOfItems(_ wheelPicker: WheelPicker) -> Int {
        return pickerData.count
    }
    
    func titleFor(_ wheelPicker: WheelPicker, at index: Int) -> String {
        return pickerData[index]
    }
    
    func wheelPicker(_ wheelPicker: WheelPicker, didSelectItemAt index: Int) {
        CurrencySettings.saveCurrency(Currency(rawValue: pickerData[index])!)
    }
}
