//
//  CharacterResponse.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// The top-level response returned by the character list endpoint.
struct CharacterResponse: Codable {
	/// The pagination metadata for the response.
	let info: Info

	/// The array of characters returned for the current page.
	let results: [Character]
}
