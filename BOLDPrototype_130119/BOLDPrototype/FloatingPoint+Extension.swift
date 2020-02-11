//
//  FloatingPoint+Extension.swift
//  BOLDPrototype
//
//  Created by Max Keuken on 25/01/2019.
//  Copyright © 2019 Bold. All rights reserved.
//

import Foundation

extension FloatingPoint {
	func toRadians() -> Self {
		return self * .pi / 180
	}
	
	func toDegrees() -> Self {
		return self * 180 / .pi
	}
}
