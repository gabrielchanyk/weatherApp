//
//  Classes.swift
//  weatherApp
//
//  Created by user196869 on 8/11/21.
//

import Foundation

//city class
class City
{
    //city properites
    let name:String
    let code:String
    let country:String
    
    //custom init
    init(withName:String,withCode:String,withCountry:String) {
        name = withName
        code = withCode
        country = withCountry
    }
}
