//
//  TravelListVC.swift
//  MapKitTravel
//
//  Created by Ramazan Burak Ekinci on 12.11.2023.
//  The First VC
//  change to first page. ViewContoller is a seconds Class

import UIKit
import CoreData

class TravelListVC: UIViewController , UITableViewDelegate, UITableViewDataSource{
   
    @IBOutlet weak var tableView: UITableView!
    var titleArray = [String]()
    var idArray = [UUID]()
    
    var chosenTitle  = ""
    var chosenTitleID : UUID?
    
    // NOT: any is not type safety
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create to added button in topbar. go to viewController in segue
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        //table view initialize
        tableView.delegate = self
        tableView.dataSource = self
        
        //call function
        getData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("NewPlaces"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
                //hucrede textine objenin ismini goster
            content.text = titleArray[indexPath.row]
            cell.contentConfiguration = content
        return cell
    }
    
    @objc func addButtonClicked(){
        chosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    @objc func getData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(request)
            
            if results.count > 0{
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject]{
                    if let title = result.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    tableView.reloadData()
                }
            }
            print("Success :)")
        }catch{
            print("get Data is Eroor :(")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenTitleID = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController"{
            let destination = segue.destination as! ViewController
            destination.selectedTitle = chosenTitle
            destination.selectedTitleID = chosenTitleID
        }
    }
}
