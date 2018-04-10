//
//  CountriesDataSource.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class CountriesDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    private let countries: [(String, String)]
    
    override init() {
        countries = Locale.isoRegionCodes.compactMap({ (regionCode) -> (String, String)? in
            guard let localizedName = Locale.current.localizedString(forRegionCode: regionCode) else { return nil }
            return (regionCode, localizedName)
        })
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row].1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let locale = countries[row].0
        print("Selected \(locale)")
    }
}
