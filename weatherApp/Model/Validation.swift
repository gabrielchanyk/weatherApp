//
//  Validation.swift
//  weatherApp
//
//  Created by user196869 on 8/10/21.
//

import Foundation
import CoreData

class Validation
{
    //shared property to be accessed outside
    static var shared = Validation()
    //private init for singleton to not be created or modified
    private init() {}
    //validate city with weather api to see if its supported
    func validateCity (name:String, code:String, country:String, completion: @escaping (Bool)->Void)
    {
        //replaces spaces to %20
        let urlCityName = name.replacingOccurrences(of: " ", with: "%20")
        //set variable for string
        var url:String
        
        //check if country is US because api has state code available only for US
        if (country == "United States")
        {
            url = "https://api.openweathermap.org/data/2.5/weather?q=\(urlCityName),\(code),US&units=metric"
        }
        else
        {
            //other countries only need city name
            url = "https://api.openweathermap.org/data/2.5/weather?q=\(urlCityName)&units=metric"
        }
        //use getInfo to get info from url
        Service.shared.getUrlInfo(url: url, NeedsKey: true){(apiData) in
            //check if there is data
            
            if  (String (data: apiData, encoding: .utf8)) != nil
            {
                //set true to completion
                completion(true)
            }
        }
    }
    
    
    
    func validateCityinDB (city:City) -> Bool
    {
        //set variable for fetchrequest
        let cityFetchRequest : NSFetchRequest<Cities> = Cities.fetchRequest()
        //set predicates
        let namePre = NSPredicate(format: "name == %@",city.name)
        let codePre = NSPredicate(format: "code == %@",city.code)
        let countryPre = NSPredicate(format: "country == %@",city.country)
        //give fetch request predicates
        cityFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePre,codePre,countryPre])
        //fetch info
        if let list = try? CoreDataStack.shared.persistentContainer.viewContext.fetch(cityFetchRequest){
            //check if there is info in list
            if (list.count != 0)
            {
                return true
            }
            else
            {
                return false
            }
        }
        return false
    }
}
