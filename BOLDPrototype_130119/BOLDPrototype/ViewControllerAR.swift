//
//  ViewControllerAR.swift
//  BOLDPrototype
//
//  Created by Max Keuken on 13/01/2019.
//  Copyright © 2019 Bold. All rights reserved.
//

// 	In dit script wordt het tweede storyboard aangestuurd.
//	In dit storyboard wordt de AR getoond.

//	Hier importeren we de verschillende modules die we binnen dit storyboard nodig hebben

import ARKit
import UIKit
import SceneKit
import CoreLocation

class ViewControllerAR: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
	
	@IBOutlet weak var sceneViewAR: ARSCNView!
	@IBOutlet weak var statusTextView: UITextView!
	
	let locationManager = CLLocationManager()
	var userLocation = CLLocation()
	
	var heading : Double! = 0.0
	var distance : Float! = 0.0 {
		didSet {
			setStatusText()
		}
	}
	//
	var status: String! {
		didSet {
			setStatusText()
		}
	}
	
	//
	func setStatusText() {
		var text = "Status: \(status!)\n"
		text += "Distance: \(String(format: "%.2f m", distance))"
		statusTextView.text = text
	}
	
	// Het 3D model wat je bij de boulder laat zien:
	var modelNode:SCNNode!
	let rootNodeName = "Rock"
	var originalTransform:SCNMatrix4!
	
    let config = ARWorldTrackingConfiguration()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set the view's delegate
		sceneViewAR.delegate = self
		
		// Create a new scene
		let scene = SCNScene()
		
		// Set the scene to the view
		sceneViewAR.scene = scene
		
		// Start location services nu voor boulder maar dit moet voor persoon zijn.
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		

		// Set the initial status
		status = "Getting user location..."
		
		// Set a padding in the text view
		statusTextView.textContainerInset = UIEdgeInsets.init(top: 20.0, left: 10.0, bottom: 10.0, right: 0.0)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Create a session configuration
		let configuration = ARWorldTrackingConfiguration()
		configuration.worldAlignment = .gravityAndHeading
		
		// Run the view's session
		sceneViewAR.session.run(configuration)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Pause the view's session
		sceneViewAR.session.pause()
	}
	
	//MARK: - CLLocationManager
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		// Implementing this method is required
		print(error.localizedDescription)
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			locationManager.requestLocation()
		}
	}
	// Op dit moment is de gebruiker statisch en de boulder dynamisch, dit moet andersom
	// Ofwel todo: switch user ~ location boulder
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.last {
			userLocation = location
			
			self.connectToDatabase()
		}
	}
	// Op dit moment is het nog hardcode 1 route, dit moet uiteindelijk een functie worden waarbij
	//	lat en long wordt opgehaald uit een database EN dat de selectie gebaseerd is op user input
	// De route voor het testen: Gebied: Franchard Isatis, Route: La Face Ouest du Rue directe
	func connectToDatabase() {
		let latitude = 48.408782
		let longitude = 2.603705
		//let heading = "0"
		self.updateLocation(latitude, longitude)
		self.status = "Boulder gevonden"
	}

	
	func updateLocation(_ latitude : Double, _ longitude : Double) {
		let location = CLLocation(latitude: latitude, longitude: longitude)
		self.distance = Float(location.distance(from: self.userLocation))
		
		if self.modelNode == nil {
			let modelScene = SCNScene(named: "art.scnassets/Rock1.dae")!
			self.modelNode = modelScene.rootNode.childNode(withName: rootNodeName, recursively: true)!
			
			// Move model's pivot to its center in the Y axis
			let (minBox, maxBox) = self.modelNode.boundingBox
			self.modelNode.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y)/2, 0)
			
			// Save original transform to calculate future rotations
			self.originalTransform = self.modelNode.transform
			
			// Position the model in the correct place
			positionModel(location)
			
			// Add the model to the scene
			sceneViewAR.scene.rootNode.addChildNode(self.modelNode)
			
		}
		else {
			// Begin animation
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 1.0
			
			// Position the model in the correct place
			positionModel(location)
			
			// End animation
			SCNTransaction.commit()
		}
	}
	
//	func makeBillboardNode(_ image: UIImage) -> SCNNode {
//		let plane = SCNPlane(width: 10, height: 10)
//		plane.firstMaterial!.diffuse.contents = image
//		let node = SCNNode(geometry: plane)
//		node.constraints = [SCNBillboardConstraint()]
//		return node
//	}
	
	// In wat volgt bereken ik de noodzakelijk transformaties om t.o.v van zelf de poi elke keer goed te plaatsen
	func positionModel(_ location: CLLocation) {
		// Rotate node
		self.modelNode.transform = rotateNode(Float(-1 * (self.heading - 180).toRadians()), self.originalTransform)
		
		// Translate node
		self.modelNode.position = translateNode(location)
		
		// Scale node
		self.modelNode.scale = scaleNode(location)
	}
	
	func rotateNode(_ angleInRadians: Float, _ transform: SCNMatrix4) -> SCNMatrix4 {
		let rotation = SCNMatrix4MakeRotation(angleInRadians, 0, 1, 0)
		return SCNMatrix4Mult(transform, rotation)
	}
	
	func scaleNode (_ location: CLLocation) -> SCNVector3 {
		let scale = min( max( Float(1000/distance), 1 ), 5 )
		return SCNVector3(x: scale, y: scale, z: scale)
	}
	
	func translateNode (_ location: CLLocation) -> SCNVector3 {
		let locationTransform =
			transformMatrix(matrix_identity_float4x4, userLocation, location)
		return positionFromTransform(locationTransform)
	}
	
	func positionFromTransform(_ transform: simd_float4x4) -> SCNVector3 {
		return SCNVector3Make(
			transform.columns.3.x, transform.columns.3.y, transform.columns.3.z
		)
	}
	
	func transformMatrix(_ matrix: simd_float4x4, _ originLocation: CLLocation, _ boulderLocation: CLLocation) -> simd_float4x4 {
		let bearing = bearingBetweenLocations(userLocation, boulderLocation)
		let rotationMatrix = rotateAroundY(matrix_identity_float4x4, Float(bearing))
		
		let position = vector_float4(0.0, 0.0, -distance, 0.0)
		let translationMatrix = getTranslationMatrix(matrix_identity_float4x4, position)
		
		let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
		
		return simd_mul(matrix, transformMatrix)
	}
	
	func getTranslationMatrix(_ matrix: simd_float4x4, _ translation : vector_float4) -> simd_float4x4 {
		var matrix = matrix
		matrix.columns.3 = translation
		return matrix
	}
	
	func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
		var matrix = matrix
		
		matrix.columns.0.x = cos(degrees)
		matrix.columns.0.z = -sin(degrees)
		
		matrix.columns.2.x = sin(degrees)
		matrix.columns.2.z = cos(degrees)
		return matrix.inverse
	}
	
	func bearingBetweenLocations(_ originLocation: CLLocation, _ boulderLocation: CLLocation) -> Double {
		let lat1 = originLocation.coordinate.latitude.toRadians()
		let lon1 = originLocation.coordinate.longitude.toRadians()
		
		let lat2 = boulderLocation.coordinate.latitude.toRadians()
		let lon2 = boulderLocation.coordinate.longitude.toRadians()
		
		let longitudeDiff = lon2 - lon1
		
		let y = sin(longitudeDiff) * cos(lat2);
		let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longitudeDiff);
		
		return atan2(y, x)
	}
}

