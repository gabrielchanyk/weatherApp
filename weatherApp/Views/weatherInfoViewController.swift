//
//  weatherInfoViewController.swift
//  weatherApp
//
//  Created by user196869 on 8/9/21.
//


import UIKit
import CoreData

class weatherInfoViewController: UIViewController
{
    @IBOutlet weak var lblHum: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    var selectedCity: Cities?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //set title to name of city selected
        navigationItem.title = selectedCity?.name
        let cityName:String = selectedCity!.name!
        //replaces spaces with %20 for url
        let urlCityName = cityName.replacingOccurrences(of: " ", with: "%20")
        var url:String
        //states only in US for this api
        if (selectedCity!.country! == "United States")
        {
            url = "https://api.openweathermap.org/data/2.5/weather?q=\(urlCityName),\(String(describing: selectedCity!.code!)),US&units=metric"
        }
        else
        {
            //other countries only need city name
            url = "https://api.openweathermap.org/data/2.5/weather?q=\(urlCityName)&units=metric"
        }
        //get info from weather api
        Service.shared.getUrlInfo(url: url, NeedsKey: true){(data) in
            //parse info
            if let weatherInfo = try? JSONDecoder().decode(WeatherInfo.self, from: data)
            {
                DispatchQueue.main.async {[unowned self]in
                    //formats for temperature
                    let mf = MeasurementFormatter()
                    mf.locale = Locale(identifier: "en_GB")
                    let temp = Measurement(value: weatherInfo.main["temp"]!, unit: UnitTemperature.celsius)
                    //set label values
                    lblHum.text = "\(String(describing: weatherInfo.main["humidity"]!))%"
                    lblTemp.text = mf.string(from: temp)
                }
            }
        }
    }
}
