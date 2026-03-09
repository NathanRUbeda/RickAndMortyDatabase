//
//  Location.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// A location in the Rick and Morty universe.
struct Location: Codable {
	/// The name of the location.
	let name: String

	/// The URL of the location's own endpoint.
	let url: String
}
