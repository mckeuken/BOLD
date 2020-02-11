//
//  ViewControllerMap.swift
//  BOLDPrototype
//
//  Created by Max Keuken on 13/01/2019.
//  Copyright © 2019 Bold. All rights reserved.
//

// 	In dit script wordt het eerste storyboard aangestuurd.
//	In dit storyboard wordt de kaart met daarop de boulders getoond.

//	Hier importeren we de verschillende modules die we binnen dit storyboard nodig hebben
import UIKit
import MapKit
import CoreLocation


// Hier definieren we de class ViewControllerMap waarmee we de MKMapView defineren
class ViewControllerMap: UIViewController {

  //
  var boulders: [Boulders] = [] 
  @IBOutlet weak var mapView: MKMapView!
  let regionRadius: CLLocationDistance = 1000
    
  // MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.showsUserLocation = true
	// Ik bepaal de start view van de kaart nu op een specifieke locatie:
	//		TODO: initialLlcation gelijk zetten aan locatie van gebruiker
    let initialLocation = CLLocation(latitude: 48.411137, longitude: 2.598642)

	centerMapOnLocation(location: initialLocation)
	mapView.delegate = self
    mapView.register(BouldersView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    loadInitialData()
    mapView.addAnnotations(boulders)
    self.mapView.showsPointsOfInterest=(false)
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkLocationAuthorizationStatus()
  }

  // MARK: - CLLocationManager
  let locationManager = CLLocationManager()
  func checkLocationAuthorizationStatus() {
    if CLLocationManager.authorizationStatus() == .authorizedAlways {
      mapView.showsUserLocation = true
    } else {
      locationManager.requestAlwaysAuthorization()
    }

  }

  // MARK: - Helper methods
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,
      latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    mapView.setRegion(coordinateRegion, animated: true)
  }

  func loadInitialData() {
    // Geef de naam van de json file (met daarin alle boulder info) hier op:
    guard let fileName = Bundle.main.path(forResource: "Boulders", ofType: "json")
      else { return }
    let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName))

    guard
      let data = optionalData,
      // Dus je hebt nu de file geopend en zoek nu naar de json entry "data"
        // Daarbinnen zoek naar de verschillende blokken en maak daar aparte strings van:
      let json = try? JSONSerialization.jsonObject(with: data),
      //
      let dictionary = json as? [String: Any],
      //
      let routes = dictionary["data"] as? [[Any]]
      else { return }
    //
    let validBoulders = routes.compactMap { Boulders(json: $0) }
    boulders.append(contentsOf: validBoulders)
  }

    
}

// MARK: - MKMapViewDelegate
extension ViewControllerMap: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
               calloutAccessoryControlTapped control: UIControl) {
    let location = view.annotation as! Boulders
    let launchOptions = [MKLaunchOptionsDirectionsModeKey:
      MKLaunchOptionsDirectionsModeDriving]
    location.mapItem().openInMaps(launchOptions: launchOptions)
  }
}

