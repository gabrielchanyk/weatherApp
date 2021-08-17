//
//  addedCitiesViewController.swift
//  weatherApp
//
//  Created by user196869 on 8/8/21.
//

import UIKit
import CoreData

class addedCitiesViewController: UITableViewController {
    
    //fetch controller
    lazy var addedcityFRC : NSFetchedResultsController<Cities> = {
        //fetch request
        let fetch : NSFetchRequest<Cities> = Cities.fetchRequest()
        //sort by country
        fetch.sortDescriptors = [NSSortDescriptor(key: "country", ascending: false)]
        //set fetch params and put to fetch conroller
        let fetchRcontroller = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext, sectionNameKeyPath: "country", cacheName: nil)
        return fetchRcontroller
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetch data
        try? addedcityFRC.performFetch()
        //fetch table
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return addedcityFRC.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // the number of rows
        return addedcityFRC.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //title for section in this case country
        return addedcityFRC.sections?[section].name ?? ""
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //set cell to custom cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "addedCell", for: indexPath) as! cityTableViewCell
        //set lbl texts
        cell.lblName.text = addedcityFRC.object(at: indexPath).name
        cell.lblCode.text = addedcityFRC.object(at: indexPath).code
        cell.lblCountry.text = addedcityFRC.object(at: indexPath).country
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //height of rows
        return 60
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //set swipe action
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { [unowned self] (action, view, completionHandler) in
            DispatchQueue.main.async {
                //delete fetch request
                let deleteFetchRequest : NSFetchRequest<Cities> = Cities.fetchRequest()
                //add predicates
                let namePre = NSPredicate(format: "name == %@", self.addedcityFRC.object(at: indexPath).name!)
                let codePre = NSPredicate(format: "code == %@",self.addedcityFRC.object(at: indexPath).code!)
                let countryPre = NSPredicate(format: "country == %@",self.addedcityFRC.object(at: indexPath).country!)
                //set predicates to fetch request
                deleteFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePre,codePre,countryPre])
                //set view context constant
                let context = CoreDataStack.shared.persistentContainer.viewContext
                if let results = try? context.fetch(deleteFetchRequest) as [NSManagedObject] {
                    // Delete city
                    for city in results {
                        context.delete(city)
                    }
                    //save results
                    CoreDataStack.shared.saveContext()
                    //fetch data
                    try? addedcityFRC.performFetch()
                    //reload
                    self.tableView.reloadData()
                }
            }
        }
        //action color
        action.backgroundColor = .systemRed
        //swipe action
        return UISwipeActionsConfiguration(actions: [action])
    }
}

//used to get update from list controller when cities are added
extension addedCitiesViewController : addCitiesDelegate
{
    //delegate function
    func updateView() {
        try? addedcityFRC.performFetch()
        tableView.reloadData()
    }
    //sending info to list view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "listCitiesSegue")
        {
            let listVC = segue.destination as! listCitiesViewController
            listVC.addcitiesDelegate = self
        }
        //set info to weather view controller
        else if (segue.identifier == "weatherInfoSegue")
        {
            let weaVC = segue.destination as! weatherInfoViewController
            //set selected index path
            let selectedIndexPath = tableView.indexPath(for: sender as! UITableViewCell)
            //send selected city data obj
            weaVC.selectedCity = addedcityFRC.object(at: selectedIndexPath!)
        }
    }
}


extension addedCitiesViewController :UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //set empty predicate
        var pre : NSPredicate? = nil
        //check if searchtext is empty
        if(!searchText.isEmpty){
            //set predicate
            pre = NSPredicate(format: "name CONTAINS[c] %@ ", searchText)
        }
        //set predicate in fetch
        addedcityFRC.fetchRequest.predicate = pre
        //fetch
        try? addedcityFRC.performFetch()
        //update table
        tableView.reloadData()
    }
}
