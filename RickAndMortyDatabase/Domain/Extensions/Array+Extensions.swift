//
//  Array+Extensions.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

extension Array where Element == Character {
	/// Appends only the elements from `contents` that are not already present in the array, based on their `id`.
	/// - Parameter contents: The array of elements to conditionally append.
	mutating func appendContentsNotAlreadyContained(contentsOf contents: [Element]) {
		var elementsToAppend: [Element] = []
		for element in contents {
			if !self.contains(where: { $0.id == element.id }) {
				elementsToAppend.append(element)
			}
		}
		self.append(contentsOf: elementsToAppend)
	}
}
