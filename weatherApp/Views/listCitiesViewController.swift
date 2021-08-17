//
//  listCitiesViewController.swift
//  weatherApp
//
//  Created by user196869 on 8/8/21.
//


//make custom cells for more info
//better print on messages
//add predicate?


import UIKit
import CoreData
//set protocol to update table after city added
protocol addCitiesDelegate : NSObjectProtocol{
    func updateView ()
}

class listCitiesViewController: UITableViewController {
    //delegate for updating previous table
    weak var addcitiesDelegate:addCitiesDelegate?
    
    //set list of cities
    var cityList:[City]? = [City]() {
        didSet{
            //reload table when value changes
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the number of rows
        return cityList?.count ?? 0
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //set cell to custom cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! cityTableViewCell
        //iterate through list
        let city = cityList?[indexPath.row]
        //set labels
        cell.lblName.text = city!.name
        cell.lblCode.text = city!.code
        cell.lblCountry.text = city!.country
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //height of row
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selected city set
        let city = cityList?[indexPath.row]
        //alert controller to print name and code
        let alert = UIAlertController(title: "Confirmation", message: "\(city!.name), \(city!.code) to be added!",
                                      preferredStyle: UIAlertController.Style.alert)
        // Cancel button to not add
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        //ok button to save to core data
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {(UIAlertAction) in
            //check if db has city
            if (!Validation.shared.validateCityinDB(city: city!))
            {
                //save to core data
                let thisCity = Cities(context: CoreDataStack.shared.persistentContainer.viewContext)
                thisCity.name = city!.name
                thisCity.code = city!.code
                thisCity.country = city!.country
                CoreDataStack.shared.saveContext()
                self.addcitiesDelegate?.updateView()
            }
        })
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
}
extension listCitiesViewController :UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //check if search text is not empty
        if(!searchText.isEmpty){
            //get info from url
            Service.shared.getUrlInfo(url: "http://gd.geobytes.com/AutoCompleteCity?callback=?&q=\(searchText)"){ (data) in
                DispatchQueue.main.async {
                    [unowned self] in
                    //get dirty json
                    let stringRep = String (data: data, encoding: .utf8)
                    //clean json
                    let dropFirst2 = String(stringRep!.dropFirst(2))
                    let cleanJson = String(dropFirst2.dropLast(2))
                    //parse json
                    guard let listOfCities = try? JSONSerialization.jsonObject(with: cleanJson.data(using: .utf8)!, options: []) as? [String] else {return}
                    //check if there is data
                    if listOfCities[0] != "%s" && listOfCities[0] != ""
                    {
                        //set variable for valid city array
                        var validCities = [City]()
                        //for each city in list
                        for city in listOfCities
                        {
                            //info is seperated by ","
                            let cityInfo = city.components(separatedBy: ", ")
                            //check if weather api has city supported
                            Validation.shared.validateCity(name: cityInfo[0], code: cityInfo[1], country: cityInfo[2]){(valid) in
                                DispatchQueue.main.async {
                                    [unowned self] in
                                    if(valid)
                                    {
                                        //if valid add to list
                                        let validCity = City.init(withName: cityInfo[0], withCode: cityInfo[1], withCountry: cityInfo[2])
                                        validCities.append(validCity)
                                        self.cityList = validCities
                                    }
                                }
                            }
                        }
                        
                    }
                    else
                    {
                        //if no result empty list
                        self.cityList = nil
                    }
                }
            }
        }
    }
}
