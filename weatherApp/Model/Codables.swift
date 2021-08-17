//
//  Codables.swift
//  weatherApp
//
//  Created by user196869 on 8/9/21.
//

import Foundation
//codable for weather info
class WeatherInfo :Codable
{
    //main is the key were info is
    var main: Dictionary<String,Double>
    var weather :[ImageInfo]
}

class ImageInfo:Codable
{
    var icon: String
    
}


class CountryInfo :Codable
{
    //country code info
    var alpha2Code: String?
}
