//
//  CountriesController.swift
//  LoginFlowDemo
//
//  Created by Toomas Vahter on 10/04/2018.
//  Copyright © 2018 Toomas Vahter. All rights reserved.
//

import UIKit

final class CountriesController: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    private let countries: [(String, String)]
    
    let pickerView: UIPickerView
    
    init(pickerView: UIPickerView) {
        countries = Locale.isoRegionCodes.compactMap({ (regionCode) -> (String, String)? in
            guard let localizedName = Locale.current.localizedString(forRegionCode: regionCode) else { return nil }
            return (regionCode, localizedName)
        }).sorted(by: { $0.1 < $1.1 })
        self.pickerView = pickerView
        super.init()
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    var selectedCountryCode: String {
        get {
            return countries[pickerView.selectedRow(inComponent: 0)].0
        }
        set {
            pickerView.selectRow(index(ofCountry: newValue), inComponent: 0, animated: false)
        }
    }
    
    func index(ofCountry country: String) -> Int {
        return countries.index(where: { $0.0.lowercased() == country.lowercased() }) ?? 0
    }
    
    
    // MARK: Picker View Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    
    // MARK: Picker View Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row].1
    }
}
