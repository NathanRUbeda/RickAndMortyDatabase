//
//  Constants.swift
//  RickAndMortyDatabase
//
//  Created by Nathan Ryan Ubeda on 08/03/26.
//

import Foundation

/// A namespace for constant values that do not change across the application.
enum Constants {
	/// The base URL for the Rick and Morty API.
	static let rickAndMortyBaseURLEndpoint = "https://rickandmortyapi.com/api/"

	/// Builds a full URL string by appending the given endpoint to the base URL.
	/// - Parameter endpoint: The API endpoint to append.
	/// - Returns: The full URL string.
	static func dispatchPath(for endpoint: String) -> String {
		Self.rickAndMortyBaseURLEndpoint + endpoint
	}
}
