//
//  ViewController.swift
//  MapKitTravel
//
//  Created by Ramazan Burak Ekinci on 11.11.2023.
//

import UIKit
import MapKit
import CoreData


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapKitOutlet: MKMapView!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var nametextField: UITextField!
    //Location
    var locationMnager = CLLocationManager()
    //lat lon globlas
    var chosenLatitude = Double()
    var chosenLongitude = Double() 
    
    //TravelListVC get data
    var selectedTitle = ""
    var selectedTitleID : UUID?
    
    //annotation variable
    var annotationTitle = ""
    var annotationSubTitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //map kit initialize
        mapKitOutlet.delegate = self
        locationMnager.delegate = self
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        locationMnager.requestWhenInUseAuthorization()
        locationMnager.startUpdatingLocation()
        
        //pinned from map
        let gestureLongRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        //min press time to add pin
        gestureLongRecognizer.minimumPressDuration = 1.5
        mapKitOutlet.addGestureRecognizer(gestureLongRecognizer)
        
        //if add button => "" , tableview => "value"
        if selectedTitle != ""{
            //CoreData
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedTitleID!.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results =  try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject] {
                        if let title =  result.value(forKey: "title") as? String{
                            annotationTitle = title
                            if let subTitle =  result.value(forKey: "subTitle") as? String{
                                annotationSubTitle = subTitle
                                if let latitude =  result.value(forKey: "latitude") as? Double{
                                    annotationLatitude = latitude
                                    if let longitude =  result.value(forKey: "longitude") as? Double{
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubTitle
                                        let cordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = cordinate
                                        
                                        mapKitOutlet.addAnnotation(annotation)
                                        nametextField.text = annotationTitle
                                        descriptionTextField.text = annotationSubTitle
                                       
                                        locationMnager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                                        let region = MKCoordinateRegion(center: cordinate, span: span)
                                        mapKitOutlet.setRegion(region, animated: true)
                                    }
                                }
                            }
                        }
                   }
                //out for loop
                }
            }catch{
                print("Eroor")
            }
        }else{
            //Add new data
            
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //location guncllendikce verilen lokasyonların aliyoruz
        
        if selectedTitle == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            //the span is zoom
            let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            let region = MKCoordinateRegion(center: location, span: span)
            mapKitOutlet.setRegion(region, animated: true)
        }
   
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseIdentifier = "123"
        var pinView = mapKitOutlet.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type:  UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //oaraya tıklandı maps info
        if selectedTitle !=  ""{
            let requestLocaiton = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocaiton) { (placemarks, eroor) in
                //closure callBack function
                
                if let placemark = placemarks{
                    if placemark.count > 0{
                        let newPlaceMark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlaceMark)
                        item.name = self.annotationTitle
                        let laaunchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: laaunchOptions)
                        
                    }
                }
                
                
            }
        }
    }
    
    @objc func chooseLocation(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            //touching
            let touchedPoint = gestureRecognizer.location(in: self.mapKitOutlet)
            let touchedCordinates = self.mapKitOutlet.convert(touchedPoint, toCoordinateFrom: self.mapKitOutlet)
            //gloval cordinates initialize
            chosenLatitude  = touchedCordinates.latitude
            chosenLongitude = touchedCordinates.longitude
            //
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCordinates
            annotation.title = nametextField.text
            annotation.subtitle = descriptionTextField.text
            mapKitOutlet.addAnnotation(annotation)
        }
    }
    
    @IBAction func saveOnClick(_ sender: Any) {
        //func? tap the save button is add to data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(nametextField.text, forKey: "title")
        newPlace.setValue(descriptionTextField.text, forKey: "subTitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("Succes")
        }catch{
            print("Eroor")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("NewPlace"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    

}

