/**

 */

import Foundation
import MapKit
import Contacts

class Boulders: NSObject, MKAnnotation {
  let title: String?
  let locationName: String
  let categorie: String
  let coordinate: CLLocationCoordinate2D

  init(title: String, locationName: String, categorie: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.locationName = locationName
    self.categorie = categorie
    self.coordinate = coordinate
    super.init()
  }

  init?(json: [Any]) {
    /**
     De json file die wordt ingelezen heeft de volgende layout:
        [0]: counter
        [1]: Naam van de route of van het gebied
        [2]: Beschrijving van de route of van het gebied
		[3]: Keywords route
        [4]: Naam van het gebied (dus dubble op voor het gebied, maar zo zie je wel in welk gebied de route valt
        [5]: Categorie: gebied of route
        [6]: land
        [7]: latitude GPS
        [8]: longitude GPS
    */
    //  Selecteer de titel van het gebied
    if let title = json[1] as? String {
      self.title = title
    } else {
      self.title = "No Title"
    }
    // Selecteer de beschrijing van het gebied / route:
    self.locationName = json[2] as! String
    // Selecteer de discipline (dus gaat het hier om een gebied of route?):
    self.categorie = json[5] as! String
    // Selecteer de GPS locaties:
    if let latitude = Double(json[7] as! String),
      let longitude = Double(json[8] as! String) {
      self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    } else {
      self.coordinate = CLLocationCoordinate2D()
    }
  }

  var subtitle: String? {
    return locationName
  }

// Selecteer het relevante icoon op basis van discipline type:
  var imageName: String? {
	if categorie == "Route2" {return "Route2"}
	if categorie == "Route3" {return "Route3"}
	if categorie == "Route3+" {return "Route3"}
    if categorie == "Route4" {return "Route4"}
	if categorie == "Route4+" {return "Route4"}
    if categorie == "Route5" {return "Route5"}
	if categorie == "Route5+" {return "Route5"}
    if categorie == "Route6A" {return "Route6"}
	if categorie == "Route6A+" {return "Route6"}
	if categorie == "Route6B" {return "Route6"}
	if categorie == "Route6B+" {return "Route6"}
	if categorie == "Route6C" {return "Route6"}
	if categorie == "Route6C+" {return "Route6"}
	if categorie == "Route7A" {return "Route7"}
	if categorie == "Route7A+" {return "Route7"}
	if categorie == "Route7B" {return "Route7"}
	if categorie == "Route7B+" {return "Route7"}
	if categorie == "Route7C" {return "Route7"}
	if categorie == "Route7C+" {return "Route7"}
	if categorie == "Route8A" {return "Route8"}
	if categorie == "Route8A+" {return "Route8"}
	if categorie == "Route8B" {return "Route8"}
	if categorie == "Route8B+" {return "Route8"}
    if categorie == "Gebied" {return "Gebied"}
    return "Gebied"
  }

  // Annotation right callout accessory opens this mapItem in Maps app
  func mapItem() -> MKMapItem {
    let addressDict = [CNPostalAddressStreetKey: subtitle!]
    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = title
    return mapItem
  }

}
