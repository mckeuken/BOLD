/**

 */

import Foundation
import MapKit

class ArtworkMarkerView: MKMarkerAnnotationView {

  override var annotation: MKAnnotation? {
    willSet {
      guard let boulder = newValue as? Boulders else { return }
      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)


        if let imageName = boulder.imageName {
          glyphImage = UIImage(named: imageName)
        } else {
          glyphImage = nil
      }
    }
  }

}

class BouldersView: MKAnnotationView {

  override var annotation: MKAnnotation? {
    willSet {
      guard let boulder = newValue as? Boulders else {return}

      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
        size: CGSize(width: 30, height: 30)))
      mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
      rightCalloutAccessoryView = mapsButton

      if let imageName = boulder.imageName {
        image = UIImage(named: imageName)
      } else {
        image = nil
      }

      let detailLabel = UILabel()
      detailLabel.numberOfLines = 0
      detailLabel.font = detailLabel.font.withSize(12)
      detailLabel.text = boulder.subtitle
      detailCalloutAccessoryView = detailLabel
    }
  }

}

