//
//  String+Extension.swift
//  BOLDPrototype
//
//  Created by Max Keuken on 25/01/2019.
//  Copyright © 2019 Bold. All rights reserved.
//

import UIKit

extension String {
	func image() -> UIImage? {
		let size = CGSize(width: 100, height: 100)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		UIColor.clear.set()
		let rect = CGRect(origin: CGPoint(), size: size)
		UIRectFill(CGRect(origin: CGPoint(), size: size))
		(self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 90)])
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
}
